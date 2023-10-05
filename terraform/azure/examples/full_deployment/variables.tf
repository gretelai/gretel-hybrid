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
