resource "aws_iam_policy" "ecr_repo_full_access" {
  name        = "EKS-ECR-FullAccess"
  description = "Allow EKS nodes full access to our two service repos"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["ecr:*"]
        Resource = [
          "arn:aws:ecr:eu-central-1:533267200006:repository/diploma-auth-service",
          "arn:aws:ecr:eu-central-1:533267200006:repository/diploma-shortener-service",
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_group_ecr_access" {
  role       = module.eks_node_group.iam_role_name
  policy_arn = aws_iam_policy.ecr_repo_full_access.arn
  depends_on = [aws_iam_policy.ecr_repo_full_access]
}
