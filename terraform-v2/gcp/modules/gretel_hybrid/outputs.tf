output "credentials_encryption_key" {
  value       = module.gretel_hybrid_connector_encryption_key.keys
  description = "The GCP KMS key that should be used for encrypting credentials for source and destination Gretel Connectors."
}
