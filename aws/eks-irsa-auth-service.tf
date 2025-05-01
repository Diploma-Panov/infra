resource "aws_iam_role" "auth_service" {
  name = "eks-auth-service-role"

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
          "${replace(local.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:diploma:auth-service"
        }
      }
    }]
  })
}

resource "aws_iam_policy" "auth_service_policy" {
  name = "eks-auth-service-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "SecretsAccess",
        Effect: "Allow",
        Action: [
          "secretsmanager:GetSecretValue"
        ],
        Resource: var.auth_service_secret_arn
      },
      {
        Sid: "S3Access",
        Effect: "Allow",
        Action: [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObjectAcl"
        ],
        Resource: "${aws_s3_bucket.auth_service_images.arn}/*"
      },
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

resource "aws_iam_role_policy_attachment" "auth_service_attach" {
  role       = aws_iam_role.auth_service.name
  policy_arn = aws_iam_policy.auth_service_policy.arn
}

resource "kubernetes_service_account" "auth_service" {
  metadata {
    name      = "auth-service"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.auth_service.arn
    }
  }
}
