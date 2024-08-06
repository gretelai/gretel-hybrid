variable "gretel_api_key" {
  type        = string
  nullable    = false
  description = "Key used to authenticate to the Gretel API. See: https://console.gretel.ai/users/me/key"
  sensitive   = true
}

variable "resource_group_name" {
  type        = string
  description = "The input name for the resource group that will hold all Gretel Azure resources."
  default     = "gretel-hybrid-env"
}

variable "region" {
  type        = string
  description = "The input region for the resource group that will hold all Gretel Azure resources. Should support GPU instances for AKS. See: https://azure.microsoft.com/en-us/explore/global-infrastructure/geographies/#overview"
  default     = "South Central US"
}

variable "deployment_name" {
  type        = string
  description = "This name will be used as the basis for most other created cloud provider resources, which will add a suffix to this string."
  default     = "gretel-hybrid-env"
}

variable "kubernetes_version" {
  type        = string
  description = "The Kubernetes version specified for the AKS cluster. eg. 1.27"
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
  description = "The version of gretel hybrid."
  default     = ""
}

variable "gretel_api_endpoint" {
  type        = string
  nullable    = false
  description = "The Gretel API endpoint. This should almost always be the default: https://api.gretel.cloud"
  default     = "https://api.gretel.cloud"
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

variable "extra_helm_values" {
  description = "Additional values to pass to the Helm chart"
  type        = any
  default     = {}
}

variable "keyvault_user_access_object_id" {
  description = "An access user to give key vault permission instead of the current user"
  type        = string
  default     = null
}

variable "enable_asymmetric_encryption" {
  description = "Controls if asymmetric encryption should be enabled"
  type        = bool
  default     = true
}

variable "max_autoscaling_size" {
  type        = number
  description = "Max autoscaling size for the default worker autoscaling group"
  default     = 5
}

variable "max_autoscaling_size_cpu" {
  type        = number
  description = "Max autoscaling size for cpu model worker autoscaling group"
  default     = 5
}

variable "max_autoscaling_size_gpu" {
  type        = number
  description = "Max autoscaling size for cpu model worker autoscaling group"
  default     = 1
}


variable "gpu_instance_type" {
  type        = string
  description = "Instance type used for GPU nodes"
  default     = "Standard_NC4as_T4_v3"
}
