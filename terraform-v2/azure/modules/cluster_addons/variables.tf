variable "nvidia_device_plugin_namespace" {
  type        = string
  nullable    = false
  description = "The kubernetes namespace to deploy nvidia-device-plugin into."
  default     = "nvidia-device-plugin"
}

variable "nvidia_device_plugin_chart_version" {
  type        = string
  nullable    = false
  description = "The helm chart version for nvidia-device-plugin. See: https://github.com/NVIDIA/k8s-device-plugin"
  default     = "0.14.1" # Released 2023-07-13
}

variable "gpu_model_worker_node_group_labels" {
  nullable    = false
  description = "The nvidia gpu plugin will use these node labels as node selectors when scheduling the model pods to gpu nodes. At least one label is required."
  type = list(object({
    key   = string
    value = string
  }))

  default = [{
    key   = "gretel-worker"
    value = "gpu-model"
  }]
}

variable "gpu_model_worker_node_group_taints" {
  nullable    = false
  description = "It is assumed that gretel gpu model nodes will be tainted so that regular workloads are not scheduled on them. Define these node taints so that the gpu driver can tolerate them when scheduling the drive pods."
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))

  default = [{
    key    = "gretel-worker"
    value  = "gpu-model"
    effect = "NoSchedule"
  }]
}
