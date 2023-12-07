variable "cluster_name" {
  type        = string
  nullable    = false
  description = "The EKS cluster name which the resources will be deployed to."
}

variable "cluster_oidc_provider_arn" {
  type        = string
  nullable    = false
  description = "The oidc_provider_arn output from the eks_cluster module."
}

variable "cluster_autoscaler_iam_role_name" {
  type        = string
  nullable    = false
  description = "The IAM role name that will be created for cluster autoscaler."
  default     = "cluster-autoscaler-role"
}

variable "cluster_autoscaler_namespace" {
  type        = string
  nullable    = false
  description = "The kubernetes namespace to deploy cluster-autoscaler into."
  default     = "kube-system"
}

variable "cluster_autoscaler_service_account" {
  type        = string
  nullable    = false
  description = "The name of the kubernetes service account that will be created for cluster autoscaler."
  default     = "cluster-autoscaler"
}

variable "cluster_autoscaler_chart_version" {
  type        = string
  nullable    = false
  description = "The helm chart version for cluster autoscaler. See: https://artifacthub.io/packages/helm/cluster-autoscaler/cluster-autoscaler"
  default     = "9.29.1" # Released 2023/06/13
}

variable "cluster_autoscaler_version" {
  type        = string
  nullable    = false
  description = "The version of cluster autoscaler to deploy. See: https://github.com/kubernetes/autoscaler/releases"
  default     = "v1.27.3" # Released 2023-07-27
}

variable "aws_tags" {
  description = "A map of tags to add to any created AWS resources."
  type        = map(any)
  default     = {}
}
