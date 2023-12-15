variable "resource_group_name" {
  type        = string
  description = "The input name for the resource group that will hold all Gretel Azure resources."
}

variable "region" {
  type        = string
  description = "The input region for the resource group that will hold all Gretel Azure resources."
}

variable "azure_tags" {
  description = "A map of tags to add to any created cloud provider resources."
  type        = map(string)
}
