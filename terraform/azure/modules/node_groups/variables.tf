variable "kubernetes_cluster_id" {
  type        = string
  description = "The resource ID for the Kubernetes cluster created in the gretel_hybrid/cluster module."
}

variable "node_subnet_id" {
  type        = string
  description = "The ID of the node subnet from the gretel_hybrid/network module."
}

variable "pod_subnet_id" {
  type        = string
  description = "The ID of the pod subnet from the gretel_hybrid/network module."
}

variable "cpu_worker_node_group_config" {
  nullable    = false
  description = "Instance config for the worker node group that runs cpu based models. See: https://docs.gretel.ai/guides/environment-setup/running-gretel-hybrid/azure-setup"
  type = object({
    instance_type        = string
    disk_size_gb         = number
    min_autoscaling_size = number
    max_autoscaling_size = number
  })

  default = {
    instance_type        = "Standard_D4as_v4"
    disk_size_gb         = 200
    min_autoscaling_size = 0
    max_autoscaling_size = 3
  }
}

variable "gpu_worker_node_group_config" {
  nullable    = false
  description = "Instance config for the worker node group that runs gpu based models. See: https://docs.gretel.ai/guides/environment-setup/running-gretel-hybrid/azure-setup"
  type = object({
    instance_type        = string
    disk_size_gb         = number
    min_autoscaling_size = number
    max_autoscaling_size = number
  })

  default = {
    instance_type        = "Standard_NC4as_T4_v3"
    disk_size_gb         = 200
    min_autoscaling_size = 0
    max_autoscaling_size = 3
  }
}

variable "cpu_worker_node_group_labels" {
  nullable    = false
  description = "Node labels for cpu workers. At least one label is required."
  type = list(object({
    key   = string
    value = string
  }))

  default = [{
    key   = "gretel-worker"
    value = "cpu"
  }]
}

variable "gpu_worker_node_group_labels" {
  nullable    = false
  description = "Node labels for gpu workers. At least one label is required."
  type = list(object({
    key   = string
    value = string
  }))

  default = [{
    key   = "gretel-worker"
    value = "gpu"
  }]
}

variable "cpu_worker_node_group_taints" {
  nullable    = false
  description = "Node taints for cpu workers. At least one taint is required."
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))

  default = [{
    key    = "gretel-worker"
    value  = "cpu"
    effect = "NoSchedule"
  }]
}

variable "gpu_worker_node_group_taints" {
  nullable    = false
  description = "Node taints for gpu workers. At least one taint is required."
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))

  default = [{
    key    = "gretel-worker"
    value  = "gpu"
    effect = "NoSchedule"
  }]
}

variable "azure_tags" {
  type        = map(string)
  description = "A map of tags to add to any created cloud provider resources."
}

