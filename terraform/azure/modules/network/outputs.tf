output "node_subnet_id" {
  value = azurerm_subnet.node_subnet.id
}

output "pod_subnet_id" {
  value = azurerm_subnet.pod_subnet.id
}
