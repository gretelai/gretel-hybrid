variable "project_id" {
  type        = string
  nullable    = false
  description = "The GCP project to deploy resources into."
}

variable "location" {
  type        = string
  nullable    = false
  description = "The GCP location/region to deploy resources into."
}

variable "deployment_name" {
  type        = string
  nullable    = false
  description = "This name will be used for certain core resources such as the GKE Cluster, the VPC, IAM service accounts, etc."
}

variable "cluster_prevent_destroy" {
  type        = bool
  description = "Prevent destruction of the created GCP GKE cluster."
  nullable    = false
  default     = true
}

variable "node_locations" {
  type        = list(string)
  nullable    = false
  description = "List of zones within the region/location which support GPU instances."
}

variable "gke_version" {
  type        = string
  nullable    = false
  default     = "1.27.3-gke.100"
  description = "Kubernetes version for the GKE cluster. Available GKE versions are documented here: https://cloud.google.com/kubernetes-engine/docs/release-notes"

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^1\\.[23][0-9]\\.[0-9]+-gke\\.[0-9]+$", var.gke_version))
    error_message = "The gke_version value should look like 1.27.3-gke.100."
  }
}

variable "bucket_location" {
  type        = string
  nullable    = false
  description = "The GCP location/region to deploy GCS resources into. See: https://cloud.google.com/storage/docs/locations"
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

variable "gretel_credentials_encryption_key_users" {
  type        = list(string)
  nullable    = false
  description = "A list of IAM principal identifiers (users, service accounts, etc.) that are allowed to perform an encrypt operation on the KMS key used for credentials encryption. See: https://cloud.google.com/iam/docs/principal-identifiers"
  default     = []
}

variable "gretel_credentials_encryption_key_prevent_destroy" {
  type        = bool
  description = "Prevent destruction of the created GCP KMS key used to encrypt credentials. If the key is destroyed, credentials cannot be decrypted and encrypted credentials will no longer be accessible."
  nullable    = false
  default     = true
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

variable "extra_helm_values" {
  description = "Additional values to pass to the Gretel Helm chart"
  type        = map(any)
  default     = {}
}
