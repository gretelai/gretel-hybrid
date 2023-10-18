# Based on: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/eks_managed_node_group/main.tf

data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.eks_version}-v*"]
  }
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix      = "VPC-CNI-IRSA"
  attach_vpc_cni_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = var.aws_tags
}


module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "19.16.0"
  cluster_name                   = var.cluster_name
  cluster_version                = var.eks_version
  cluster_endpoint_public_access = true
  manage_aws_auth_configmap      = false

  vpc_id                   = var.vpc_id
  subnet_ids               = var.vpc_private_subnets
  control_plane_subnet_ids = var.vpc_intra_subnets

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
  }

  eks_managed_node_group_defaults = {

    # We are using the IRSA created below for permissions
    # However, we have to deploy with the policy attached FIRST (when creating a fresh cluster)
    # and then turn this off after the cluster/node group is created. Without this initial policy,
    # the VPC CNI fails to assign IPs and nodes cannot join the cluster
    # See https://github.com/aws/containers-roadmap/issues/1666 for more context
    iam_role_attach_cni_policy = true

    # This will ensure the bootstrap user data is used to join the node
    # By default, EKS managed node groups will not append bootstrap script;
    # this adds it back in using the default template provided by the module
    # Note: this assumes the AMI provided is an EKS optimized AMI derivative
    enable_bootstrap_user_data = true
  }

  eks_managed_node_groups = {
    # The default node group will run core cluster workloads such as coredns, cluster-autoscaler, and the gretel agent.
    default_node_group = {
      ami_type = "AL2_x86_64"
      min_size = var.default_node_group_config.min_autoscaling_size
      max_size = var.default_node_group_config.max_autoscaling_size
      ami_id   = data.aws_ami.eks_default.image_id

      instance_types = var.default_node_group_config.instance_types
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = var.default_node_group_config.disk_size_gb
          }
        }
      }

      # Allow shell access via AWS SSM
      iam_role_additional_policies = {
        AmazonSSMManagedEC2InstanceDefaultPolicy = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
      }
    }
  }

  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    ingress_cluster_all = {
      description                   = "Cluster to node all ports/protocols"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 0
      type                          = "ingress"
      source_cluster_security_group = true
    }
    egress_all = {
      description = "Node all egress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = var.aws_tags
}
