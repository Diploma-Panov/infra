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
        ]
        Resource = "*"
      },
      {
        Sid: "DynamoDBAccess"
        Effect: "Allow"
        Action = [
          "dynamodb:*"
        ]
        Resource = [
          aws_dynamodb_table.shortener_links.arn,
          "${aws_dynamodb_table.shortener_links.arn}/index/*"
        ]
      }
    ]
  })
}
