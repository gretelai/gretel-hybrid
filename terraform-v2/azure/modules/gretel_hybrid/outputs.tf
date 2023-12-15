output "key_vault_key_name" {
  value = azurerm_key_vault_key.gretel_key.name
}
output "key_vault_url" {
  value = azurerm_key_vault.gretel_key_vault.vault_uri
}

output "key_vault_id" {
  value = azurerm_key_vault.gretel_key_vault.id
}

output "storage_account_id" {
  value = azurerm_storage_account.gretel_hybrid.id
}
