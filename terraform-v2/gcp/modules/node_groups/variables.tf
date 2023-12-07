variable "project_id" {
  type        = string
  description = "ID of GCP project in which cluster resources will be deployed"
}

variable "location" {
  type        = string
  nullable    = false
  description = "The GCP location/region to deploy resources into."
}

variable "cluster_name" {
  type        = string
  nullable    = false
  description = "The existing GKE cluster which the node groups will be associated with."
}

variable "iam_service_account_name" {
  type        = string
  description = "The name for the GCP IAM Service Account that will be created for the Gretel node pools."
}

variable "cpu_node_group_config" {
  nullable    = false
  description = "Machine config for the Gretel CPU workers node group that runs Gretel CPU based models."
  type = object({
    node_locations       = list(string)
    name                 = string
    machine_type         = string
    ip_range_name_pods   = string
    min_autoscaling_size = number
    max_autoscaling_size = number
    disk_size_gb         = number
    node_labels = list(object({
      key   = string
      value = string
    }))
    node_taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  })
}

variable "gpu_node_group_config" {
  nullable    = false
  description = "Machine config for the Gretel GPU workers node group that runs Gretel GPU based models."
  type = object({
    node_locations       = list(string)
    name                 = string
    machine_type         = string
    gpu_type             = string
    gpu_count            = number
    ip_range_name_pods   = string
    min_autoscaling_size = number
    max_autoscaling_size = number
    disk_size_gb         = number
    node_labels = list(object({
      key   = string
      value = string
    }))
    node_taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  })
}
