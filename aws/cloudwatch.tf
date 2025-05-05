resource "aws_iam_policy" "cw_logs_write" {
  name        = "EKSFluentBitCloudWatchLogs"
  description = "Allow EKS Fluent Bit to push logs to CloudWatch Logs"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchLogGroup"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups"
        ]
        Resource = "arn:aws:logs:*:*:log-group:*"
      },
      {
        Sid    = "AllowCloudWatchLogStreamAndPut"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:log-group:*:log-stream:*"
      }
    ]
  })
}


resource "aws_iam_role" "fluentbit" {
  name = "eks-fluentbit-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = local.oidc_provider_arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${local.oidc_provider_url}:sub" = "system:serviceaccount:kube-system:fluentbit"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "fluentbit_logs" {
  role       = aws_iam_role.fluentbit.name
  policy_arn = aws_iam_policy.cw_logs_write.arn
}

resource "kubernetes_service_account" "fluentbit" {
  metadata {
    name      = "fluentbit"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.fluentbit.arn
    }
  }
}

resource "helm_release" "fluentbit" {
  name       = "aws-for-fluent-bit"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  version    = "0.1.35"
  namespace  = "kube-system"

  values = [
    file("${path.module}/fluentbit-values.yaml")
  ]

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = kubernetes_service_account.fluentbit.metadata[0].name
  }

  set {
    name  = "cloudWatch.region"
    value = "eu-central-1"
  }

  set {
    name  = "cloudWatch.logGroupName"
    value = "/aws/eks/${module.eks.cluster_name}/application"
  }

  set {
    name  = "cloudWatch.autoCreateGroup"
    value = "true"
  }

  set {
    name  = "cloudWatch.logStreamPrefix"
    value = "fluent-bit-"
  }

  set {
   name  = "filter.kubernetes.namespaces[0]"
   value = "default"
  }

  # set {
  #  name  = "filter.kubernetes.exclude.namespaces[0]"
  #  value = "kube-system"
  # }
}