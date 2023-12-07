output "note" {
  value = "Please use the following GCP KMS key to encrypt credentials: ${module.gretel_hybrid.credentials_encryption_key.credentials-encryption-key}"
}
