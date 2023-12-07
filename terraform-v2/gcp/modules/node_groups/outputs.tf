output "cpu_node_group_labels" {
  value       = var.cpu_node_group_config.node_labels
  description = "The k8s labels assigned to the CPU model workers."
}

output "gpu_node_group_labels" {
  value       = var.gpu_node_group_config.node_labels
  description = "The k8s labels assigned to the GPU model workers."
}

output "cpu_node_group_taints" {
  value       = var.cpu_node_group_config.node_taints
  description = "The k8s taints assigned to the CPU model workers."
}

output "gpu_node_group_taints" {
  value       = var.gpu_node_group_config.node_taints
  description = "The k8s taints assigned to the GPU model workers."
}
