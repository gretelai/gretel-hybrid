terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

resource "azurerm_resource_group" "gretel_hybrid" {
  name     = var.resource_group_name
  location = var.region

  tags = var.azure_tags
}
