resource "null_resource" "deploy_kubernetes_configs" {
  provisioner "local-exec" {
    command = "envsubst < ../k8s/ingress.yaml.template > ../k8s/rendered-ingress.yaml && kubectl apply -f ../k8s --recursive"
    environment = {
      KUBECONFIG = "../kubeconfig"
      ACM_CERTIFICATE_ARN  = var.acm_certificate_arn
    }
  }

  triggers = {
    always_run = timestamp()
  }

  depends_on = [
    kubernetes_service_account.alb_ingress_sa,
    kubernetes_service_account.auth_service,
    kubernetes_service_account.shortener_service,
    kubernetes_config_map.auth_service_configs,
    kubernetes_config_map.shortener_service_configs
  ]
}
