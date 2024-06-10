variable "name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "min_autoscaling_size" {
  type = number
}

variable "max_autoscaling_size" {
  type = number
}

variable "subnet_ids" {
  type = list(string)
}

variable "disk_size_gb" {
  type = number
}

variable "node_labels" {
  nullable = false
  type = list(object({
    key   = string
    value = string
  }))
}

variable "node_taints" {
  nullable = false
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
}

variable "node_resource_hints" {
  nullable = false
  type = list(object({
    key   = string
    value = string
  }))
  default = []
}

variable "ami_base" {
  type = string
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
