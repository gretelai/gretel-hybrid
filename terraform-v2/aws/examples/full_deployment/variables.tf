variable "region" {
  type        = string
  description = "The AWS region to deploy resources into."
}

variable "deployment_name" {
  type        = string
  nullable    = false
  description = "This name will be used for certain core resources such as the EKS Cluster, the VPC, IAM roles, etc."
}

variable "kubernetes_version" {
  type        = string
  nullable    = false
  default     = "1.27"
  description = "Kubernetes version for the EKS cluster. Available EKS versions are documented here: https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html"

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^1\\.[23][0-9]$", var.kubernetes_version))
    error_message = "The kubernetes_version value should look like 1.27."
  }
}

variable "cluster_admin_roles" {
  type        = map(string)
  description = "Optional list of IAM Role arns you would like added to the aws-auth ConfigMap with K8s admin permissions. Without specifying one of cluster_admin_roles or cluster_admin_users, the only IAM identity with access to the K8s cluster will be the cluster creator."
  default     = {}
}

variable "cluster_admin_users" {
  type        = map(string)
  description = "Optional list of IAM User arns you would like added to the aws-auth ConfigMap with K8s admin permissions. Without specifying one of cluster_admin_roles or cluster_admin_users, the only IAM identity with access to the K8s cluster will be the cluster creator."
  default     = {}
}

variable "gretel_source_bucket_name" {
  type        = string
  nullable    = false
  description = "The AWS S3 bucket name that will be used for Gretel Hybrid's source bucket."
}

variable "gretel_sink_bucket_name" {
  type        = string
  nullable    = false
  description = "The AWS S3 bucket name that will be used for Gretel Hybrid's sink bucket."
}

variable "gretel_api_key" {
  type        = string
  nullable    = false
  description = "The API key used by the Gretel Hybrid Deployment to authenticate to the Gretel API."
  sensitive   = true
}

# The following are variables that don't need to be changed in most normal
# deployment scenarios.

variable "gretel_api_endpoint" {
  type        = string
  nullable    = false
  description = "The Gretel API endpoint. This should almost always be the default: https://api.gretel.cloud"
  default     = "https://api.gretel.cloud"
}

variable "gretel_helm_repo" {
  type        = string
  description = "The gretel helm repository URL."
  default     = "https://gretel-blueprints-pub.s3.us-west-2.amazonaws.com/helm-charts/stable/"
}

variable "gretel_chart" {
  type        = string
  nullable    = false
  description = "The helm chart for gretel hybrid."
  default     = "gretel-data-plane"
}

variable "gretel_projects" {
  type        = list(string)
  nullable    = false
  description = "List of projects to operate on. Leave blank for all projects"
  default     = []
}

variable "gretel_credentials_encryption_user_arns" {
  type        = list(string)
  nullable    = false
  description = "List of ARNs (users, roles, ...) of users that should be granted encrypt permission on the KMS key used for credentials encryption."
  default     = []
}

variable "extra_helm_values" {
  description = "Additional values to pass to the Helm chart"
  type        = any
  default     = {}
}

variable "_enable_asymmetric_encryption" {
  description = "Internal only, do not modify"
  type        = bool
  default     = false
}
