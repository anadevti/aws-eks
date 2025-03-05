terraform {
  backend "remote" {
    organization = "anadevti"
    workspaces {
      name = "backstage-eks-aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Módulo para criar a VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true # Habilita o NAT Gateway para subnets privadas
  single_nat_gateway = true # Usa um único NAT Gateway para reduzir custos
}

# Módulo para criar o cluster EKS
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.0.0"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.27"

  vpc_id                   = module.vpc.vpc_id # ID da VPC criada pelo módulo VPC
  subnet_ids               = module.vpc.private_subnets # Subnets privadas da VPC

  # Configuração do Managed Node Group
  eks_managed_node_groups = {
    my_node_group = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t2.micro"] # Tipo de instância dos nós
    }
  }
}