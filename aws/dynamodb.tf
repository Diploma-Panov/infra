resource "aws_dynamodb_table" "shortener_links" {
  name           = "ShortUrlStatsProd"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "urlCode"
  range_key      = "bucket"

  attribute {
    name = "urlCode"
    type = "S"
  }

  attribute {
    name = "bucket"
    type = "S"
  }
}

data "aws_iam_policy_document" "node_dynamodb" {
  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:UpdateItem",
    ]
    resources = [
      aws_dynamodb_table.shortener_links.arn,
      "${aws_dynamodb_table.shortener_links.arn}/index/*"
    ]
  }
}

resource "aws_iam_policy" "node_dynamodb" {
  name   = "eks-node-DynamoDB-access"
  policy = data.aws_iam_policy_document.node_dynamodb.json
}

resource "aws_iam_role_policy_attachment" "node_dynamodb_attach" {
  role       = module.eks_node_group.iam_role_name
  policy_arn = aws_iam_policy.node_dynamodb.arn
}
