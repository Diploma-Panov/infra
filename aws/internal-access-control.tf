resource "aws_security_group" "managed_services_sg" {
  name        = "managed-services-sg"
  description = "Allows access to Redis, Kafka, DynamoDB, RDS from EKS nodes"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group" "eks_nodes_sg" {
  name        = "eks-nodes-sg"
  description = "EKS nodes outbound SG"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "allow_cross_eks_node_communication" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
}

resource "aws_security_group_rule" "allow_eks_to_managed_services" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.managed_services_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
}

resource "aws_security_group_rule" "allow_eks_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks_nodes_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}