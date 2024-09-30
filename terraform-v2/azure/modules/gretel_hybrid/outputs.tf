output "key_vault_key_name" {
  value = azurerm_key_vault_key.gretel_key.name
}
output "key_vault_url" {
  value = azurerm_key_vault.gretel_key_vault.vault_uri
}

output "key_vault_id" {
  value = azurerm_key_vault.gretel_key_vault.id
}

output "key_vault_public_key_pem" {
  value = azurerm_key_vault_key.gretel_key.public_key_pem
}

output "storage_account_id" {
  value = azurerm_storage_account.gretel_hybrid.id
}

output "storage_account_name" {
  value = azurerm_storage_account.gretel_hybrid.name
}

output "storage_sink_container" {
  value = azurerm_storage_container.sink.name
}

output "workflow_worker_client_id" {
  value = azurerm_user_assigned_identity.gretel_workflow_worker.client_id
}

output "model_worker_client_id" {
  value = azurerm_user_assigned_identity.gretel_model_worker.client_id
}

output "workflow_worker_id" {
  value = azurerm_user_assigned_identity.gretel_workflow_worker.id
}

output "model_worker_id" {
  value = azurerm_user_assigned_identity.gretel_model_worker.id
}
