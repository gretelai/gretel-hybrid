locals {
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = var.aws_tags
}

data "aws_availability_zones" "available" {}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 5.1.1"


  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = local.azs
  public_subnets  = var.vpc_public_subnet_cidrs
  intra_subnets   = var.vpc_intra_subnet_cidrs
  private_subnets = var.vpc_private_subnet_cidrs

  enable_nat_gateway     = true
  single_nat_gateway     = true
  create_egress_only_igw = true
  enable_dns_hostnames   = true

  public_subnet_tags = {
    "type"                   = "public"
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "type"                            = "private"
    "kubernetes.io/role/internal-elb" = 1
  }

  intra_subnet_tags = {
    "type" = "intra"
  }

  tags = merge(local.tags, {
    "kubernetes.io/cluster/${var.vpc_name}" = "owned"
  })
}
