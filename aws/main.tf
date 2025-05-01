provider "aws" {
  region = "eu-central-1"
}

provider "aws" {
  alias  = "useast1"
  region = "us-east-1"
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.cluster_auth.token
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster_auth.token
}

data "aws_eks_cluster_auth" "cluster_auth" {
  name = module.eks.cluster_name
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "diploma-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  public_subnet_tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/diploma-cluster" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/diploma-cluster" = "shared"
  }

  enable_nat_gateway = true
  single_nat_gateway = true
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.9.0"

  access_entries = {
    kubernetes_deployer = {
      principal_arn = var.deployer_arn
      kubernetes_groups = []

      policy_associations = {
        eks_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAdminPolicy"
          access_scope = { type = "cluster" }
        }
        eks_cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }

  cluster_name                    = "diploma-cluster"
  cluster_version                 = "1.32"
  cluster_endpoint_public_access  = true
  enable_irsa                     = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
}

module "eks_node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/eks-managed-node-group"
  version = "20.9.0"

  cluster_name            = module.eks.cluster_name
  cluster_version         = module.eks.cluster_version
  subnet_ids              = module.vpc.private_subnets
  name                    = "default"
  cluster_service_cidr    = module.eks.cluster_service_cidr
  cluster_endpoint        = module.eks.cluster_endpoint
  cluster_auth_base64     = module.eks.cluster_certificate_authority_data
  min_size                = 1
  max_size                = 4
  desired_size            = 2
  instance_types          = ["t3.medium"]

  vpc_security_group_ids = [
    aws_security_group.eks_nodes_sg.id,
    module.eks.node_security_group_id
  ]

  depends_on = [ module.eks ]
}

# module "alb" {
#   source  = "terraform-aws-modules/alb/aws"
#   version = "8.7.0"
#
#   name                  = "diploma-alb"
#   load_balancer_type    = "application"
#   internal              = false
#
#   vpc_id          = module.vpc.vpc_id
#   subnets         = module.vpc.public_subnets
#   security_groups = [module.eks.cluster_primary_security_group_id]
#
#   enable_deletion_protection = false
# }
