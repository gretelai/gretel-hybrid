output "cluster_name" {
  value       = module.gke.name
  description = "The name of the created GKE cluster."
}

output "endpoint" {
  value       = module.gke.endpoint
  description = "The k8s API endpoint for the created GKE cluster."
}

output "ca_certificate" {
  value       = module.gke.ca_certificate
  description = "The CA certificate for the created GKE cluster, used for the k8s Terraform provider."
}
