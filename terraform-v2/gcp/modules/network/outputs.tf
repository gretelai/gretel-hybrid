output "network_name" {
  value       = module.vpc.name
  description = "The name of the created GCP Network."
}

output "subnet_name" {
  value       = var.subnet_name
  description = "The name of the primary subnetwork created within the GCP Network."
}

output "ip_range_name_pods" {
  value       = local.ip_range_name_pods
  description = "The IP range alias within the primary subnetwork that will be used for k8s pods."
}

output "ip_range_name_services" {
  value       = local.ip_range_name_services
  description = "The IP range alias within the primary subnetwork that will be used for k8s services."
}
