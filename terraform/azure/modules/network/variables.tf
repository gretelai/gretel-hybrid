variable "vnet_name" {
  type        = string
  description = "The virtual network will be created with this name. This vnet will be used by the AKS cluster."
}

variable "vnet_cidr" {
  type        = string
  nullable    = false
  description = "The virtual network CIDR. eg. 10.0.0.0/16"

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", var.vnet_cidr))
    error_message = "The VNET CIDR should be a valid CIDR. eg. 10.0.0.0/16."
  }
}

variable "node_subnet_cidr" {
  type        = string
  nullable    = false
  description = "Node subnet CIDR. This subnet will be used by AKS nodes. eg. 10.0.0.0/22 would provide 1024 addresses for nodes (10.0.0.0 - 10.0.3.255)."

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", var.node_subnet_cidr))
    error_message = "The VNET CIDR should be a valid CIDR within the range provided for the virtual network."
  }
}

variable "pod_subnet_cidr" {
  type        = string
  nullable    = false
  description = "Pod subnet CIDR. This subnet will be used by AKS pods. eg. 10.0.16.0/20 would provide 4096 addresses for pods (10.0.16.0 - 10.0.31.255)."

  validation {
    # regex(...) fails if it cannot find a match
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", var.pod_subnet_cidr))
    error_message = "The VNET CIDR should be a valid /16 CIDR within the range provided for the virtual network."
  }
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
  type        = map(string)
  description = "A map of tags to add to any created cloud provider resources."
}
