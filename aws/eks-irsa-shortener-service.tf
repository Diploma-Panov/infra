resource "aws_iam_role" "shortener_service" {
  name = "eks-shortener-service-role"

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
          "${replace(local.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:default:shortener-service"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "shortener_service_policy" {
  name = "eks-shortener-service-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "LoggingAccess",
        Effect: "Allow",
        Action: [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource: "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "shortener_service_attach" {
  role       = aws_iam_role.shortener_service.name
  policy_arn = aws_iam_policy.shortener_service_policy.arn
}

resource "kubernetes_service_account" "shortener_service" {
  metadata {
    name      = "shortener-service"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.shortener_service.arn
    }
  }
}
