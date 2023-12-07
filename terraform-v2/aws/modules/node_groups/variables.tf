variable "cpu_node_group_config" {
  nullable    = false
  description = "EC2 instance config for the Gretel CPU workers node group that runs Gretel CPU based models."
  type = object({
    name                 = string
    instance_type        = string
    subnet_ids           = list(string)
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
  description = "EC2 instance config for the Gretel GPU workers node group that runs Gretel GPU based models."
  type = object({
    name                 = string
    instance_type        = string
    subnet_ids           = list(string)
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


variable "aws_tags" {
  description = "A map of tags to add to any created AWS resources."
  type        = map(any)
  default     = {}
}


# --- Passed from cluster module ---

variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type    = string
  default = "1.27"
}

variable "cluster_endpoint" {
  type = string
}

variable "cluster_auth_base64" {
  type = string
}

variable "cluster_node_security_group_id" {
  type = string
}
