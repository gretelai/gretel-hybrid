variable "cluster_name" {
  type        = string
  nullable    = false
  description = "This name will be used for certain core resources such as the EKS Cluster and the VPC."
}

variable "eks_version" {
  type        = string
  nullable    = false
  default     = "1.27"
  description = "Kubernetes version for the EKS cluster. Available EKS versions are documented here: https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html"

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^1\\.[23][0-9]$", var.eks_version))
    error_message = "The eks_version value should look like 1.27."
  }
}

variable "default_node_group_config" {
  nullable    = false
  description = "EC2 instance config for the default node group that runs core cluster workloads (eg. coredns, cluster-autoscaler, etc.)"
  type = object({
    instance_types       = list(string)
    disk_size_gb         = number
    min_autoscaling_size = number
    max_autoscaling_size = number
  })
}

variable "vpc_id" {
  type        = string
  description = "An existing VPC ID which your cluster will be deployed into."
}

variable "vpc_private_subnets" {
  type        = list(string)
  description = "A list of subnet IDs where the nodes/node groups will be provisioned."
}

variable "vpc_intra_subnets" {
  type        = list(string)
  description = "A list of subnet IDs where the EKS cluster control plane (ENIs) will be provisioned."
}

variable "aws_tags" {
  description = "A map of tags to add to any created AWS resources."
  type        = map(any)
  default     = {}
}
