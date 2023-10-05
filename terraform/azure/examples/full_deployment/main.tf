terraform {
  # backend "azurerm" {
  #   resource_group_name  = "tfstate"
  #   storage_account_name = "tfstategretel"
  #   container_name       = "tfstate"
  #   key                  = "gretel-hybrid-env.tfstate"
  # }
}

provider "azurerm" {
  features {}
}

provider "kubernetes" {
  host                   = module.cluster.kubeconfig_host
  username               = module.cluster.kubeconfig_username
  password               = module.cluster.kubeconfig_password
  client_certificate     = base64decode(module.cluster.kubeconfig_client_certificate)
  client_key             = base64decode(module.cluster.kubeconfig_client_key)
  cluster_ca_certificate = base64decode(module.cluster.kubeconfig_cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = module.cluster.kubeconfig_host
    username               = module.cluster.kubeconfig_username
    password               = module.cluster.kubeconfig_password
    client_certificate     = base64decode(module.cluster.kubeconfig_client_certificate)
    client_key             = base64decode(module.cluster.kubeconfig_client_key)
    cluster_ca_certificate = base64decode(module.cluster.kubeconfig_cluster_ca_certificate)
  }
}

locals {
  resource_group_name                  = var.resource_group_name
  region                               = var.region
  deployment_name                      = var.deployment_name
  kubernetes_version                   = var.kubernetes_version
  gretel_api_key                       = var.gretel_api_key
  gretel_storage_account_name          = var.gretel_storage_account_name
  gretel_source_storage_container_name = var.gretel_source_storage_container_name
  gretel_sink_storage_container_name   = var.gretel_sink_storage_container_name

  cpu_worker_node_label = {
    key   = "gretel-worker"
    value = "cpu"
  }
  gpu_worker_node_label = {
    key   = "gretel-worker"
    value = "gpu"
  }

  azure_tags = {
    gretel-hybrid-cluster = local.deployment_name
  }
}

module "prereqs" {
  source              = "../../modules/prereqs"
  resource_group_name = local.deployment_name
  region              = local.region
  azure_tags          = local.azure_tags
}

module "network" {
  source                         = "../../modules/network"
  existing_resource_group_name   = module.prereqs.hybrid_resource_group_name
  existing_resource_group_region = module.prereqs.hybrid_resource_group_region
  vnet_name                      = "${local.deployment_name}-vnet"
  vnet_cidr                      = "10.0.0.0/16"
  node_subnet_cidr               = "10.0.0.0/22"  // 10.0.0.0 - 10.0.3.255, 1024 addresses
  pod_subnet_cidr                = "10.0.16.0/20" // 10.0.16.0 - 10.0.31.255, 4096 addresses
  azure_tags                     = local.azure_tags
}

module "cluster" {
  source                         = "../../modules/cluster"
  existing_resource_group_name   = module.prereqs.hybrid_resource_group_name
  existing_resource_group_region = module.prereqs.hybrid_resource_group_region
  cluster_name                   = "${local.deployment_name}-cluster"
  kubernetes_version             = local.kubernetes_version
  service_cidr                   = "10.0.32.0/20"
  dns_service_ip                 = "10.0.32.10"
  node_subnet_id                 = module.network.node_subnet_id
  pod_subnet_id                  = module.network.pod_subnet_id

  # ----- Standard K8s Workers -----
  default_node_group_config = {
    instance_type        = "Standard_D2_v2"
    disk_size_gb         = 100
    min_autoscaling_size = 1
    max_autoscaling_size = 3
  }

  azure_tags = local.azure_tags
}

module "cluster_addons" {
  depends_on = [module.cluster]
  source     = "../../modules/cluster_addons"
  gpu_worker_node_group_labels = [{
    key   = local.gpu_worker_node_label.key
    value = local.gpu_worker_node_label.value
  }]
  gpu_worker_node_group_taints = [{
    key    = local.gpu_worker_node_label.key
    value  = local.gpu_worker_node_label.value
    effect = "NoSchedule"
  }]
}

module "node_groups" {
  depends_on            = [module.cluster_addons]
  source                = "../../modules/node_groups"
  kubernetes_cluster_id = module.cluster.kubernetes_cluster_id
  node_subnet_id        = module.network.node_subnet_id
  pod_subnet_id         = module.network.pod_subnet_id

  # ----- Gretel CPU Workers -----
  cpu_worker_node_group_config = {
    instance_type        = "Standard_D4as_v4"
    disk_size_gb         = 200
    min_autoscaling_size = 0
    max_autoscaling_size = 3
  }
  cpu_worker_node_group_labels = [{
    key   = local.cpu_worker_node_label.key
    value = local.cpu_worker_node_label.value
  }]
  cpu_worker_node_group_taints = [{
    key    = local.cpu_worker_node_label.key
    value  = local.cpu_worker_node_label.value
    effect = "NoSchedule"
  }]

  # ----- Gretel GPU Workers -----
  gpu_worker_node_group_config = {
    instance_type        = "Standard_NC4as_T4_v3"
    disk_size_gb         = 200
    min_autoscaling_size = 0
    max_autoscaling_size = 3
  }
  gpu_worker_node_group_labels = [{
    key   = local.gpu_worker_node_label.key
    value = local.gpu_worker_node_label.value
  }]
  gpu_worker_node_group_taints = [{
    key    = local.gpu_worker_node_label.key
    value  = local.gpu_worker_node_label.value
    effect = "NoSchedule"
  }]

  azure_tags = local.azure_tags
}

module "gretel_hybrid" {
  source                               = "../../modules/gretel_hybrid"
  existing_resource_group_name         = module.prereqs.hybrid_resource_group_name
  existing_resource_group_region       = module.prereqs.hybrid_resource_group_region
  gretel_storage_account_name          = local.gretel_storage_account_name
  gretel_source_storage_container_name = local.gretel_source_storage_container_name
  gretel_sink_storage_container_name   = local.gretel_sink_storage_container_name

  gretel_api_key              = local.gretel_api_key
  gretel_worker_pod_memory_gb = "10" # 16GB workers, leaving headroom for DaemonSets. Any higher and pods cannot be scheduled.
  gretel_worker_pod_cpu_count = "2"  # 4 vCPU workers

  gretel_gpu_worker_node_selector = module.node_groups.gpu_node_group_labels
  gretel_gpu_worker_tolerations   = module.node_groups.gpu_node_group_taints

  gretel_cpu_worker_node_selector = module.node_groups.cpu_node_group_labels
  gretel_cpu_worker_tolerations   = module.node_groups.cpu_node_group_taints

  gretel_worker_env_vars = {
    EXAMPLE_VAR = "EXAMPLE_VALUE"
  }

  azure_tags = local.azure_tags
}
