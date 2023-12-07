output "note" {
  value = "Please use the following AWS KMS key ARN to encrypt credentials: ${module.gretel_hybrid.credentials_encryption_key_arn}"
}
