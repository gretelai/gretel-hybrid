variable "project_id" {
  type        = string
  nullable    = false
  description = "The GCP project to deploy resources into."
}

variable "location" {
  type        = string
  nullable    = false
  description = "The GCP location/region to deploy resources into."
}

variable "cluster_name" {
  type        = string
  nullable    = false
  description = "This name will be used for certain core resources such as the EKS Cluster and the VPC."
}

variable "cluster_prevent_destroy" {
  type        = bool
  description = "Prevent destruction of the created GCP GKE cluster."
  nullable    = false
  default     = true
}

variable "gke_version" {
  type        = string
  nullable    = false
  default     = "1.27.9-gke.1092000"
  description = "Kubernetes version for the GKE cluster. Available GKE versions are documented here: https://cloud.google.com/kubernetes-engine/docs/release-notes"

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^1\\.[23][0-9]\\.[0-9]+-gke\\.[0-9]+$", var.gke_version))
    error_message = "The gke_version value should look like 1.27.3-gke.100."
  }
}

variable "default_node_group_config" {
  nullable    = false
  description = "Machine config for the default node group that runs core cluster workloads."
  type = object({
    machine_type         = string
    disk_size_gb         = number
    min_autoscaling_size = number
    max_autoscaling_size = number
  })
}

variable "network_name" {
  type        = string
  description = "The existing network to host the cluster in."
  nullable    = false
}

variable "subnet_name" {
  type        = string
  description = "The existing subnetwork to host the cluster in."
  nullable    = false
}

variable "ip_range_name_pods" {
  type        = string
  description = "The name of the secondary subnet ip range to use for pods."
  nullable    = false
}

variable "ip_range_name_services" {
  type        = string
  description = "The name of the secondary subnet ip range to use for services."
  nullable    = false
}
