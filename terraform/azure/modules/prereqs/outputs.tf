output "hybrid_resource_group_name" {
  value = azurerm_resource_group.gretel_hybrid.name
}

output "hybrid_resource_group_region" {
  value = azurerm_resource_group.gretel_hybrid.location
}
