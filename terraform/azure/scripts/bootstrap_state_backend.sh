#!/usr/bin/env bash

set -euo pipefail

# Default values
DEFAULT_RESOURCE_GROUP_NAME="tfstate"
DEFAULT_STORAGE_ACCOUNT_NAME="tfstategretel"
DEFAULT_CONTAINER_NAME="tfstate"
DEFAULT_LOCATION="southcentralus"

# Help message function
print_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  -h, --help                 Show this help message"
  echo "  -r, --resource-group NAME  Specify the resource group name. This resource group should not exist yet and will be created. (default: $DEFAULT_RESOURCE_GROUP_NAME)"
  echo "  -s, --storage-account NAME Specify the storage account name. This storage account should not exist yet and will be created. (default: $DEFAULT_STORAGE_ACCOUNT_NAME)"
  echo "  -c, --container NAME       Specify the blob container name. (default: $DEFAULT_CONTAINER_NAME)"
  echo "  -l, --location NAME        Specify the location/region (default: $DEFAULT_LOCATION)"
  echo
  echo "Description:"
  echo "  This script creates an Azure resource group, a storage account, and a blob container for managing Terraform state."
  exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
  -h | --help)
    print_help
    ;;
  -r | --resource-group)
    RESOURCE_GROUP_NAME="$2"
    shift 2
    ;;
  -s | --storage-account)
    STORAGE_ACCOUNT_NAME="$2"
    shift 2
    ;;
  -c | --container)
    CONTAINER_NAME="$2"
    shift 2
    ;;
  -l | --location)
    LOCATION="$2"
    shift 2
    ;;
  *)
    echo "Invalid option: $1"
    print_help
    ;;
  esac
done

# Create resource group
az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION"

# Create storage account
az storage account create --resource-group "$RESOURCE_GROUP_NAME" --name "$STORAGE_ACCOUNT_NAME" --sku Standard_LRS --encryption-services blob

# Create blob container
az storage container create --name "$CONTAINER_NAME" --account-name "$STORAGE_ACCOUNT_NAME"

# Generate and display Terraform backend configuration
cat <<EOF

Example Terraform Backend Configuration:
========================================

terraform {
  backend "azurerm" {
    resource_group_name   = "$RESOURCE_GROUP_NAME"
    storage_account_name  = "$STORAGE_ACCOUNT_NAME"
    container_name        = "$CONTAINER_NAME"
    key                   = "gretel-hybrid-env.tfstate"
  }
}

EOF
