resource "null_resource" "deploy_k8s" {
  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig \
        --region eu-central-1 \
        --name ${module.eks.cluster_name}

      kubectl apply -f ../k8s --recursive
    EOT
  }

  depends_on = [
    module.eks_node_group,
    kubernetes_service_account.auth_service,
    kubernetes_service_account.shortener_service,
    kubernetes_config_map.shortener_service_configs,
    kubernetes_config_map.auth_service_configs
  ]
}

resource "kubernetes_ingress_v1" "diploma" {
  metadata {
    name      = "diploma-ingress"
    namespace = "default"

    annotations = {
      "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
      "alb.ingress.kubernetes.io/listen-ports"     = jsonencode([
        { HTTP  = 80  },
        { HTTPS = 443 }
      ])
      "alb.ingress.kubernetes.io/redirect-http-to-https" = "true"
      "alb.ingress.kubernetes.io/certificate-arn"  = var.alb_certificate_arn
      "alb.ingress.kubernetes.io/ssl-policy"       = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTP"
    }
  }

  timeouts {
    create = "1200s"
  }

  wait_for_load_balancer = true

  spec {
    ingress_class_name = "alb"

    rule {
      host = "api.urls.mpanov.com"
      http {
        path {
          path     = "/api/auth/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_account.auth_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
        path {
          path     = "/api/shrt/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_account.shortener_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }

    rule {
      host = "mpanov.com"
      http {
        path {
          path     = "/r/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_account.shortener_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_service_account.shortener_service,
    kubernetes_service_account.auth_service
  ]
}

data "aws_lb" "diploma_ingress_alb" {
  tags = {
    "elbv2.k8s.aws/cluster" = module.eks.cluster_name
    "ingress.k8s.aws/stack" = "default/diploma-ingress"
  }

  depends_on = [
    kubernetes_ingress_v1.diploma
  ]
}


