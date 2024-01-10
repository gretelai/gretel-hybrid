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

variable "gretel_hybrid_namespace" {
  type        = string
  nullable    = false
  description = "The kubernetes namespace that gretel resources will be deployed in."
  default     = "gretel-hybrid"
}

variable "gretel_workflow_worker_service_account" {
  type        = string
  nullable    = false
  description = "The Kubernetes service account that will be created for Gretel workflow workers."
  default     = "workflow-worker"
}

variable "gretel_model_worker_service_account" {
  type        = string
  nullable    = false
  description = "The Kubernetes service account that will be created for Gretel model workers."
  default     = "model-worker"
}

variable "kubernetes_oidc_issuer_url" {
  description = "The issuer URL corresponding to the Kubernetes cluster"
  type        = string
}


variable "gretel_storage_account_name" {
  type        = string
  nullable    = false
  description = "The Azure Storage Account name that will be created and used for gretel hybrid's source and sink storage containers."
}

variable "gretel_source_storage_container_name" {
  type        = string
  nullable    = false
  description = "The Azure Storage Container name that will be created and used for gretel hybrid's source bucket."
}

variable "gretel_sink_storage_container_name" {
  type        = string
  nullable    = false
  description = "The Azure Storage Container name that will be created and used for gretel hybrid's sink bucket."
}

variable "gretel_key_vault_name" {
  type        = string
  description = "The name of the Key Vault associated with the Gretel deployment."
  default     = "gretelkeyvault"
}

variable "gretel_key_vault_key_name" {
  type        = string
  description = "The name of the Key associated with the Gretel deployment."
  default     = "gretel-key"
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
  description = "Memory request and limit for the model worker pods."
  default     = "10"
}

variable "gretel_model_worker_pod_cpu_count" {
  type        = string
  description = "Integer value specifying number of CPUs model worker pods will have configured in their requests."
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

  default = {
    gretel-worker = "gpu-model"
  }
}

variable "gretel_cpu_model_worker_node_selector" {
  description = "Node selector for scheduling CPU based model jobs. Set to null to allow CPU jobs to be scheduled on any node (not recommended)."
  type        = map(string)

  default = {
    gretel-worker = "cpu-model"
  }
}

variable "gretel_gpu_model_worker_tolerations" {
  description = "Node tolerations for model jobs scheduled on gpu workers."
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

variable "gretel_cpu_model_worker_tolerations" {
  description = "Node tolerations for model jobs scheduled on cpu workers."
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))

  default = [{
    key    = "gretel-worker"
    value  = "cpu-model"
    effect = "NoSchedule"
  }]
}

variable "gretel_image_registry_override_host" {
  type        = string
  description = "URL to override the image registry used to fetch worker images"
  default     = ""
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of the Azure Resource Group created in the gretel_hybrid/prereqs module."
}

variable "existing_resource_group_region" {
  type        = string
  description = "The region of the Azure Resource Group created in the gretel_hybrid/prereqs module."
}

variable "azure_tags" {
  description = "A map of tags to add to any created cloud provider resources."
  type        = map(any)
  default     = {}
}

variable "extra_helm_values" {
  description = "Additional values to pass to the Helm chart"
  type        = map(any)
  default     = {}
}
