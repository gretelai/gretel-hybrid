terraform {
  # backend "s3" {
  #   bucket = "my-unique-tf-state-bucket-name"
  #   key    = "state/aws-gretel-hybrid/terraform.tfstate"
  #   region = "us-west-2"
  # }
}

# Uncomment the aws provider to deploy this module directly (if you are not calling it from a parent module)
# provider "aws" {
#   region = local.region
#   # Uncomment the below block if you are authenticated in Account A and need to assume a role and deploy to Account B
#   # assume_role {
#   #   role_arn = "arn:aws:iam::012345678912:role/TerraformExecution"
#   # }
# }


provider "kubernetes" {
  host                   = module.cluster.cluster_endpoint
  cluster_ca_certificate = module.cluster.cluster_ca_certificate
  token                  = data.aws_eks_cluster_auth.output_cluster_auth.token
}

provider "helm" {
  kubernetes {
    host                   = module.cluster.cluster_endpoint
    cluster_ca_certificate = module.cluster.cluster_ca_certificate
    token                  = data.aws_eks_cluster_auth.output_cluster_auth.token
  }
}

# The above kubernetes and helm providers require the oidc token from the cluster_auth
data "aws_eks_cluster_auth" "output_cluster_auth" {
  name = module.cluster.cluster_name
}

# Locals in this main.tf are primarily used to define things that are re-used between all modules.
locals {
  region = var.region
  # These labels will be used for three things:
  #   - Kubernetes node labels, so that cpu or gpu nodes can be selected when scheduling jobs.
  #   - Kubernetes taints, so that other k8s pods are not scheduled to gretel nodes.
  #   - Kubernetes tolerations which are applied to gretel jobs so that they can be scheduled to tainted nodes.
  # See:
  #   - Labels: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
  #   - Taints/Tolerations: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/
  cpu_model_worker_node_label = {
    key   = "gretel-worker"
    value = "cpu-model"
  }
  gpu_model_worker_node_label = {
    key   = "gretel-worker"
    value = "gpu-model"
  }

  # aws_tags may be passed to all modules and all created resources will have these tags.
  # This provides for easy identification of all resources created by these modules.
  aws_tags = {
    gretel-hybrid-cluster = var.deployment_name
  }
}

module "network" {
  source                   = "../../modules/network"
  vpc_name                 = "${var.deployment_name}-vpc"
  vpc_cidr                 = "10.0.0.0/16"
  vpc_private_subnet_cidrs = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
  vpc_intra_subnet_cidrs   = ["10.0.48.0/24", "10.0.49.0/24", "10.0.50.0/24"]
  vpc_public_subnet_cidrs  = ["10.0.52.0/24", "10.0.53.0/24", "10.0.54.0/24"]
  aws_tags                 = local.aws_tags
}

# Creates the EKS cluster and its VPC and associated resources.
module "cluster" {
  source       = "../../modules/cluster"
  cluster_name = "${var.deployment_name}-cluster"
  eks_version  = var.kubernetes_version
  aws_tags     = local.aws_tags

  # ----- Standard K8s Workers -----
  default_node_group_config = {
    instance_types       = ["t3.large"]
    disk_size_gb         = 100
    min_autoscaling_size = 1
    max_autoscaling_size = var.max_autoscaling_size
  }

  vpc_id              = module.network.vpc_id
  vpc_private_subnets = module.network.vpc_private_subnets
  vpc_intra_subnets   = module.network.vpc_intra_subnets
}


module "node_groups" {
  source   = "../../modules/node_groups"
  aws_tags = local.aws_tags

  cluster_name                   = module.cluster.cluster_name
  cluster_version                = module.cluster.cluster_version
  cluster_endpoint               = module.cluster.cluster_endpoint
  cluster_auth_base64            = base64encode(module.cluster.cluster_ca_certificate)
  cluster_node_security_group_id = module.cluster.cluster_node_security_group_id

  cpu_node_group_config = {
    name                 = "gretel-workers-cpu-models"
    instance_type        = "m5.xlarge"
    subnet_ids           = module.network.vpc_private_subnets
    min_autoscaling_size = 0
    max_autoscaling_size = var.max_autoscaling_size
    disk_size_gb         = 200
    node_labels          = [local.cpu_model_worker_node_label]
    node_taints = [
      {
        key    = local.cpu_model_worker_node_label.key
        value  = local.cpu_model_worker_node_label.value
        effect = "NoSchedule"
      }
    ]
    node_resource_hints = [
      {
        key   = "ephemeral-storage"
        value = "100G"
      }
    ]
  }
  gpu_node_group_config = {
    name                 = "gretel-workers-gpu-models"
    instance_type        = "g5.xlarge"
    subnet_ids           = module.network.vpc_private_subnets
    min_autoscaling_size = 0
    max_autoscaling_size = var.max_autoscaling_size
    disk_size_gb         = 200
    node_labels          = [local.gpu_model_worker_node_label]
    node_taints = [
      {
        key    = local.gpu_model_worker_node_label.key
        value  = local.gpu_model_worker_node_label.value
        effect = "NoSchedule"
      }
    ]
    node_resource_hints = [
      {
        key   = "ephemeral-storage"
        value = "100G"
      }
    ]
  }
}

module "cluster_auth" {
  source              = "../../modules/cluster_auth"
  cluster_name        = module.cluster.cluster_name
  cluster_admin_roles = var.cluster_admin_roles
  cluster_admin_users = var.cluster_admin_users
  worker_node_iam_role_arns = [
    module.cluster.cluster_node_iam_role_arn,
    module.node_groups.cpu_node_group_node_iam_role_arn,
    module.node_groups.gpu_node_group_node_iam_role_arn
  ]
}

module "cluster_addon_cluster_autoscaler" {
  source                           = "../../modules/cluster_addon_cluster_autoscaler"
  cluster_name                     = module.cluster.cluster_name
  cluster_oidc_provider_arn        = module.cluster.cluster_oidc_provider_arn
  cluster_autoscaler_iam_role_name = "${module.cluster.cluster_name}-cluster-autoscaler-role"
  aws_tags                         = local.aws_tags
}

module "cluster_addon_nvidia_driver" {
  source                             = "../../modules/cluster_addon_nvidia_driver"
  gpu_model_worker_node_group_labels = module.node_groups.gpu_node_group_labels
  gpu_model_worker_node_group_taints = module.node_groups.gpu_node_group_taints
}

# Creates the source and sink buckets, sets up the IAM role for gretel agent to use with
# permissions to those buckets, and then deploys the gretel hybrid helm chart.
module "gretel_hybrid" {
  source                            = "../../modules/gretel_hybrid"
  cluster_name                      = module.cluster.cluster_name
  cluster_oidc_provider_arn         = module.cluster.cluster_oidc_provider_arn
  gretel_source_bucket_name         = var.gretel_source_bucket_name
  gretel_sink_bucket_name           = var.gretel_sink_bucket_name
  gretel_api_key                    = var.gretel_api_key
  gretel_api_endpoint               = var.gretel_api_endpoint
  gretel_hybrid_projects            = var.gretel_projects
  gretel_model_worker_pod_memory_gb = "14" # 16GB workers, leaving a little bit of headroom
  gretel_model_worker_pod_cpu_count = "2"  # 4 vCPU workers

  gretel_gpu_model_worker_node_selector = {
    for label in module.node_groups.gpu_node_group_labels : label.key => label.value
  }
  gretel_gpu_model_worker_tolerations = module.node_groups.gpu_node_group_taints

  gretel_cpu_model_worker_node_selector = {
    for label in module.node_groups.cpu_node_group_labels : label.key => label.value
  }
  gretel_cpu_model_worker_tolerations = module.node_groups.cpu_node_group_taints

  gretel_worker_env_vars = {
    EXAMPLE_VAR = "EXAMPLE_VALUE"
  }

  gretel_credentials_encryption_key_user_arns = var.gretel_credentials_encryption_user_arns

  aws_tags = local.aws_tags

  gretel_helm_repo     = var.gretel_helm_repo
  gretel_chart         = var.gretel_chart
  gretel_chart_version = var.gretel_chart_version

  # This allows deploying multiple instances into the same AWS account, as long
  # as their deployment names are different.
  gretel_credentials_encryption_key_alias = "${var.deployment_name}-credentials-encryption-key"
  gretel_workflow_worker_iam_role_name    = "${var.deployment_name}-workflow-worker-role"
  gretel_workflow_worker_iam_policy_name  = "${var.deployment_name}-workflow-worker-policy"
  gretel_model_worker_iam_role_name       = "${var.deployment_name}-model-worker-role"
  gretel_model_worker_iam_policy_name     = "${var.deployment_name}-model-worker-policy"

  extra_helm_values = var.extra_helm_values

  enable_asymmetric_encryption = var.enable_asymmetric_encryption
}
