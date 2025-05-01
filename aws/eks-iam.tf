data "aws_caller_identity" "current" {}

locals {
  oidc_provider_url = module.eks.cluster_oidc_issuer_url
  oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(local.oidc_provider_url, "https://", "")}"
}

resource "aws_iam_policy" "alb_ingress_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy for ALB Ingress Controller"
  policy      = file("${path.module}/alb-ingress-controller-policy.json")
}

resource "aws_iam_role" "alb_ingress_controller" {
  name = "eks-alb-ingress-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = local.oidc_provider_arn
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${replace(local.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:alb-ingress-controller"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "alb_ingress_policy" {
  role       = aws_iam_role.alb_ingress_controller.name
  policy_arn = aws_iam_policy.alb_ingress_controller.arn
}

resource "kubernetes_service_account" "alb_ingress_sa" {
  metadata {
    name      = "alb-ingress-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_ingress_controller.arn
    }
  }
}
