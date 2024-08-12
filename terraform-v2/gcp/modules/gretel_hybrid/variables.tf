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

variable "bucket_location" {
  type        = string
  nullable    = false
  description = "The GCP location/region to deploy GCS resources into. See: https://cloud.google.com/storage/docs/locations"
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
variable "gretel_chart_version" {
  type        = string
  nullable    = true
  description = "The helm chart version for gretel hybrid."
  default     = ""
}

variable "gretel_hybrid_namespace" {
  type        = string
  nullable    = false
  description = "The kubernetes namespace that gretel resources will be deployed in."
  default     = "gretel-hybrid"
}

variable "gretel_credentials_encryption_keyring_name" {
  type        = string
  description = "Name for the GCP KMS keyring that will be created."
  nullable    = false
  default     = "gretel-hybrid"
}

variable "gretel_credentials_encryption_key_name" {
  type        = string
  description = "Name for the GCP KMS key that will be created. This key will be used to encrypt connector credentials."
  nullable    = false
  default     = "credentials-encryption-key"
}

variable "gretel_credentials_encryption_key_prevent_destroy" {
  type        = bool
  description = "Prevent destruction of the created GCP KMS key used to encrypt credentials. If the key is destroyed, credentials cannot be decrypted and encrypted credentials will no longer be accessible."
  nullable    = false
  default     = true
}

variable "gretel_credentials_encryption_key_users" {
  type        = list(string)
  nullable    = false
  description = "A list of IAM principal identifiers (users, service accounts, etc.) that are allowed to perform an encrypt operation on the KMS key used for credentials encryption. See: https://cloud.google.com/iam/docs/principal-identifiers"
  default     = []
}

variable "gretel_workflow_worker_k8s_service_account" {
  type        = string
  nullable    = false
  description = "The Kubernetes service account that will be created for Gretel GCC workers."
  default     = "workflow-worker"
}

variable "gretel_workflow_worker_gcp_service_account" {
  type        = string
  nullable    = false
  description = "The GCP Service Account that will be created for the Gretel GCC worker service account."
  default     = "gretel-hybrid-workflow-worker"
}

variable "gretel_model_worker_k8s_service_account" {
  type        = string
  nullable    = false
  description = "The Kubernetes service account that will be created for Gretel model workers."
  default     = "model-worker"
}

variable "gretel_model_worker_gcp_service_account" {
  type        = string
  nullable    = false
  description = "The GCP Service Account that will be created for the Gretel model worker service account."
  default     = "gretel-hybrid-model-worker"
}

variable "gretel_source_bucket_name" {
  type        = string
  nullable    = false
  description = "The GCS bucket name that will be created and used for gretel hybrid's source bucket."
}

variable "gretel_sink_bucket_name" {
  type        = string
  nullable    = false
  description = "The GCS bucket name that will be created and used for gretel hybrid's sink bucket."
}

variable "gretel_hybrid_projects" {
  type        = list(string)
  description = "Determines the gretel projects that the hybrid agent pull jobs for. If none is provided, then jobs from all projects be fetched (by user or by team if the user is part of a team)."
  default     = []
}

variable "gretel_api_key" {
  type        = string
  nullable    = false
  description = "Key used to authenticate to the Gretel API."
  sensitive   = true
}

variable "gretel_api_endpoint" {
  type        = string
  nullable    = false
  description = "The Gretel API endpoint. This should almost always be the default: https://api.gretel.cloud"
  default     = "https://api.gretel.cloud"
}

variable "gretel_worker_env_vars" {
  type        = map(string)
  description = "Environment variables to be passed to the worker pods."
  default     = {}
}

variable "gretel_model_worker_pod_memory_gb" {
  type        = string
  description = "Memory request and limit for the worker pods."
  default     = "14"
}

variable "gretel_model_worker_pod_cpu_count" {
  type        = string
  description = "Integer value specifying number of CPUs worker pods will have configured in their requests."
  default     = "1"
}

variable "gretel_max_workers" {
  type        = string
  description = "Number of parallel jobs that can be spawned concurrently from the agent. This cannot exceed the number of licensed workers purchased from gretel."
  default     = "0"
}

variable "gretel_gpu_model_worker_node_selector" {
  description = "Node selector for scheduling GPU based model jobs. Set to null to allow GPU jobs to be scheduled on any node (not recommended)."
  type        = map(string)
}

variable "gretel_cpu_model_worker_node_selector" {
  description = "Node selector for scheduling CPU based model jobs. Set to null to allow CPU jobs to be scheduled on any node (not recommended)."
  type        = map(string)
}

variable "gretel_gpu_model_worker_tolerations" {
  description = "Node tolerations for jobs scheduled on gpu workers."
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
}

variable "gretel_cpu_model_worker_tolerations" {
  description = "Node tolerations for jobs scheduled on cpu workers."
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
}

variable "gretel_image_registry_override_host" {
  type        = string
  description = "URL to override the image registry used to fetch worker images"
  default     = ""
}

variable "extra_helm_values" {
  description = "Additional values to pass to the Helm chart"
  type        = any
  default     = {}
}

variable "skip_kubernetes_resources" {
  description = "Control whether this module deploys the k8s namespace and the Gretel Hybrid Helm Chart."
  type        = bool
  default     = false
}

variable "enable_asymmetric_encryption" {
  description = "Controls if asymmetric encryption should be enabled"
  type        = bool
  default     = true
}
