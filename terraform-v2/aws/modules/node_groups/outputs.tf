output "cpu_node_group_node_iam_role_arn" {
  value = module.cpu_node_group.node_iam_role_arn
}

output "cpu_node_group_labels" {
  value = module.cpu_node_group.node_group_labels
}

output "cpu_node_group_taints" {
  value = module.cpu_node_group.node_group_taints
}

output "gpu_node_group_node_iam_role_arn" {
  value = module.gpu_node_group.node_iam_role_arn
}

output "gpu_node_group_labels" {
  value = module.gpu_node_group.node_group_labels
}

output "gpu_node_group_taints" {
  value = module.gpu_node_group.node_group_taints
}
