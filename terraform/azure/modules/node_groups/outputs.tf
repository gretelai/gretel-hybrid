output "cpu_node_group_labels" {
  value = azurerm_kubernetes_cluster_node_pool.cpu_node_pool.node_labels
}

output "gpu_node_group_labels" {
  value = azurerm_kubernetes_cluster_node_pool.gpu_node_pool.node_labels
}

output "cpu_node_group_taints" {
  value = var.cpu_worker_node_group_taints
}

output "gpu_node_group_taints" {
  value = var.gpu_worker_node_group_taints
}
