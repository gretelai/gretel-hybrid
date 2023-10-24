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
