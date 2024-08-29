# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.cluster.ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.cluster.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.cluster.ca_certificate)
  }
}

# Uncomment the google and google-beta providers to deploy this module directly (if you are not calling it from a parent module)
# provider "google" {
#   project = "your-project-here"
#   region  = "us-central1"
# }

# provider "google-beta" {
#   project = "your-project-here"
#   region  = "us-central1"
# }

locals {
  cpu_model_worker_node_label = {
    key   = "gretel-worker"
    value = "cpu-model"
  }
  gpu_model_worker_node_label = {
    key   = "gretel-worker"
    value = "gpu-model"
  }
}

module "network" {
  source               = "../../modules/network"
  project_id           = var.project_id
  location             = var.location
  vpc_name             = "${var.deployment_name}-vpc"
  subnet_name          = "${var.deployment_name}-subnet"
  subnet_cidr_primary  = "10.0.0.0/20"
  subnet_cidr_pods     = "10.0.16.0/20"
  subnet_cidr_services = "10.0.32.0/20"
  nat_name             = "${var.deployment_name}-nat"
}

module "cluster" {
  depends_on              = [module.network]
  source                  = "../../modules/cluster"
  project_id              = var.project_id
  location                = var.location
  cluster_name            = "${var.deployment_name}-cluster"
  cluster_prevent_destroy = var.cluster_prevent_destroy
  gke_version             = var.gke_version
  default_node_group_config = {
    machine_type         = "e2-standard-2"
    disk_size_gb         = 100
    min_autoscaling_size = 1
    max_autoscaling_size = var.max_autoscaling_size
  }
  network_name           = module.network.network_name
  subnet_name            = module.network.subnet_name
  ip_range_name_pods     = module.network.ip_range_name_pods
  ip_range_name_services = module.network.ip_range_name_services
}

module "node_groups" {
  source                   = "../../modules/node_groups"
  project_id               = var.project_id
  location                 = var.location
  cluster_name             = module.cluster.cluster_name
  iam_service_account_name = "${var.deployment_name}-node-sa"
  cpu_node_group_config = {
    node_locations       = var.node_locations
    name                 = "${var.deployment_name}-cpu-model-workers"
    machine_type         = "n2-standard-4"
    ip_range_name_pods   = module.network.ip_range_name_pods
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
  }
  gpu_node_group_config = {
    node_locations       = var.node_locations
    name                 = "${var.deployment_name}-gpu-model-workers"
    machine_type         = "g2-standard-4"
    gpu_type             = "nvidia-l4"
    gpu_count            = 1
    ip_range_name_pods   = module.network.ip_range_name_pods
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
  }
}

module "gretel_hybrid" {
  source                            = "../../modules/gretel_hybrid"
  project_id                        = var.project_id
  location                          = var.location
  bucket_location                   = var.bucket_location
  gretel_source_bucket_name         = var.gretel_source_bucket_name
  gretel_sink_bucket_name           = var.gretel_sink_bucket_name
  gretel_api_key                    = var.gretel_api_key
  gretel_api_endpoint               = var.gretel_api_endpoint
  gretel_hybrid_projects            = var.gretel_projects
  gretel_model_worker_pod_memory_gb = "10"
  gretel_model_worker_pod_cpu_count = "2"

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

  gretel_credentials_encryption_key_users           = var.gretel_credentials_encryption_key_users
  gretel_credentials_encryption_key_prevent_destroy = var.gretel_credentials_encryption_key_prevent_destroy

  gretel_helm_repo     = var.gretel_helm_repo
  gretel_chart         = var.gretel_chart
  gretel_chart_version = var.gretel_chart_version

  # This allows deploying multiple instances into the same GCP project, as long
  # as their deployment names are different.
  gretel_credentials_encryption_keyring_name = var.deployment_name # Random suffix will be added to the keyring
  gretel_credentials_encryption_key_name     = "credentials-encryption-key"
  gretel_workflow_worker_gcp_service_account = "${var.deployment_name}-workflow-worker"
  gretel_model_worker_gcp_service_account    = "${var.deployment_name}-model-worker"

  extra_helm_values = var.extra_helm_values

  enable_asymmetric_encryption = var.enable_asymmetric_encryption
}
