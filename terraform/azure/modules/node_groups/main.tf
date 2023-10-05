terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "gpu_node_pool" {
  name                  = "gretelgpu"
  kubernetes_cluster_id = var.kubernetes_cluster_id
  vm_size               = var.gpu_worker_node_group_config.instance_type
  os_disk_size_gb       = var.gpu_worker_node_group_config.disk_size_gb
  min_count             = var.gpu_worker_node_group_config.min_autoscaling_size
  max_count             = var.gpu_worker_node_group_config.max_autoscaling_size
  vnet_subnet_id        = var.node_subnet_id
  pod_subnet_id         = var.pod_subnet_id
  enable_auto_scaling   = true
  node_labels = {
    for label in var.gpu_worker_node_group_labels : (label.key) => label.value
  }
  node_taints = [
    for taint in var.gpu_worker_node_group_taints :
    "${taint.key}=${taint.value}:${taint.effect}"
  ]
  tags = var.azure_tags
}

resource "azurerm_kubernetes_cluster_node_pool" "cpu_node_pool" {
  name                  = "gretelcpu"
  kubernetes_cluster_id = var.kubernetes_cluster_id
  vm_size               = var.cpu_worker_node_group_config.instance_type
  os_disk_size_gb       = var.cpu_worker_node_group_config.disk_size_gb
  min_count             = var.cpu_worker_node_group_config.min_autoscaling_size
  max_count             = var.cpu_worker_node_group_config.max_autoscaling_size
  enable_auto_scaling   = true
  vnet_subnet_id        = var.node_subnet_id
  pod_subnet_id         = var.pod_subnet_id
  node_labels = {
    for label in var.cpu_worker_node_group_labels : (label.key) => label.value
  }
  node_taints = [
    for taint in var.cpu_worker_node_group_taints :
    "${taint.key}=${taint.value}:${taint.effect}"
  ]
  tags = var.azure_tags
}
