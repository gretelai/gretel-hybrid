variable "cluster_name" {
  type        = string
  description = "Input that will determine the AKS cluster name."
}

variable "kubernetes_version" {
  type        = string
  description = "The Kubernetes version specified for the AKS cluster. eg. 1.27"
}

variable "service_cidr" {
  type        = string
  description = "The network range for Kubernetes services to use within the cluster's vnet."

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", var.service_cidr))
    error_message = "The Service CIDR should be a valid CIDR. eg. 10.0.0.0/16."
  }
}

variable "dns_service_ip" {
  type        = string
  description = "IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns). Must be within the range provided in service_cidr variable."
}

variable "node_subnet_id" {
  type        = string
  description = "The ID of the node subnet from the gretel_hybrid/network module."
}

variable "pod_subnet_id" {
  type        = string
  description = "The ID of the pod subnet from the gretel_hybrid/network module."
}

variable "log_analytics_workspace_sku" {
  type        = string
  default     = "PerGB2018"
  description = "The SKU (pricing level) of the Log Analytics workspace. For new subscriptions the SKU should be set to PerGB2018"
}

variable "log_retention_in_days" {
  type        = number
  default     = 30
  description = "The retention period for cluster logs in days"
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of the Azure Resource Group created in the gretel_hybrid/prereqs module."
}

variable "existing_resource_group_region" {
  type        = string
  description = "The region of the Azure Resource Group created in the gretel_hybrid/prereqs module."
}

variable "default_node_group_config" {
  nullable    = false
  description = "Instance config for the default node group that runs core cluster workloads (eg. dns, cluster-autoscaler, gretel-agent, etc.)"
  type = object({
    instance_type        = string
    disk_size_gb         = number
    min_autoscaling_size = number
    max_autoscaling_size = number
  })

  default = {
    instance_type        = "Standard_B4ms"
    disk_size_gb         = 100
    min_autoscaling_size = 1
    max_autoscaling_size = 3
  }
}


variable "azure_tags" {
  description = "A map of tags to add to any created cloud provider resources."
  type        = map(string)
}
