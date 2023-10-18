output "node_iam_role_arn" {
  value = module.node_group.iam_role_arn
}

output "node_group_labels" {
  value = var.node_labels
}

output "node_group_taints" {
  value = var.node_taints
}
