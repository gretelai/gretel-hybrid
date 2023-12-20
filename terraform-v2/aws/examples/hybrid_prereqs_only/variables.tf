variable "region" {
  type        = string
  description = "The AWS region to deploy resources into."
}

variable "existing_eks_cluster_name" {
  type        = string
  nullable    = false
  description = "The name of the existing EKS cluster which you will utilize to deploy Gretel Hybrid. This cluster should reside within the AWS account you are deploying this module to."
}

variable "existing_eks_cluster_oidc_provider_arn" {
  type        = string
  nullable    = false
  description = "The arn for the existing EKS cluster's OIDC provider. Find this under 'Identity Providers' in the AWS IAM Console. See: https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html"
}

variable "existing_gretel_hybrid_namespace" {
  type        = string
  nullable    = false
  description = "The kubernetes namespace that gretel resources will be deployed in. This is used for the IRSA roles trust policy."
}

variable "deployment_name" {
  type        = string
  nullable    = false
  description = "This name will be used to name certain core resources."
}

variable "gretel_source_bucket_name" {
  type        = string
  nullable    = false
  description = "The AWS S3 bucket name that will be used to create Gretel Hybrid's source bucket."
}

variable "gretel_sink_bucket_name" {
  type        = string
  nullable    = false
  description = "The AWS S3 bucket name that will be used to create Gretel Hybrid's sink bucket."
}

variable "gretel_credentials_encryption_user_arns" {
  type        = list(string)
  nullable    = false
  description = "List of ARNs (users, roles, ...) of users that should be granted encrypt permission on the KMS key used for credentials encryption."
  default     = []
}
