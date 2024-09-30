output "resource_group_name" {
  value = module.prereqs.hybrid_resource_group_name
}

output "kubernetes_oidc_issuer_url" {
  value = module.cluster.kubernetes_oidc_issuer_url
}

output "key_vault_key_name" {
  value = module.gretel_hybrid.key_vault_key_name
}
output "key_vault_url" {
  value = module.gretel_hybrid.key_vault_url
}

output "key_vault_id" {
  value = module.gretel_hybrid.key_vault_id
}

output "key_vault_public_key_pem" {
  value = module.gretel_hybrid.key_vault_public_key_pem
}

output "storage_account_id" {
  value = module.gretel_hybrid.storage_account_id
}

output "storage_account_name" {
  value = module.gretel_hybrid.storage_account_name
}

output "storage_sink_container" {
  value = module.gretel_hybrid.storage_sink_container
}

output "workflow_worker_client_id" {
  value = module.gretel_hybrid.workflow_worker_client_id
}

output "model_worker_client_id" {
  value = module.gretel_hybrid.model_worker_client_id
}

output "workflow_worker_id" {
  value = module.gretel_hybrid.workflow_worker_id
}

output "model_worker_id" {
  value = module.gretel_hybrid.model_worker_id
}
