terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

resource "azurerm_log_analytics_solution" "gretel_hybrid_cluster" {
  location              = var.existing_resource_group_region
  resource_group_name   = var.existing_resource_group_name
  solution_name         = "ContainerInsights"
  workspace_name        = azurerm_log_analytics_workspace.gretel_hybrid_cluster.name
  workspace_resource_id = azurerm_log_analytics_workspace.gretel_hybrid_cluster.id
  tags                  = var.azure_tags

  plan {
    product   = "OMSGallery/ContainerInsights"
    publisher = "Microsoft"
  }
}

resource "azurerm_log_analytics_workspace" "gretel_hybrid_cluster" {
  location            = var.existing_resource_group_region
  name                = "${var.cluster_name}-logs-workspace"
  resource_group_name = var.existing_resource_group_name
  retention_in_days   = var.log_retention_in_days
  sku                 = var.log_analytics_workspace_sku
  tags                = var.azure_tags
}

resource "azurerm_kubernetes_cluster" "gretel_hybrid_cluster" {
  name                = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  location            = var.existing_resource_group_region
  resource_group_name = var.existing_resource_group_name
  dns_prefix          = "gretel"

  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.gretel_hybrid_cluster.id
  }

  default_node_pool {
    name                = "default"
    vm_size             = var.default_node_group_config.instance_type
    enable_auto_scaling = true
    min_count           = var.default_node_group_config.min_autoscaling_size
    max_count           = var.default_node_group_config.max_autoscaling_size
    os_disk_size_gb     = var.default_node_group_config.disk_size_gb
    vnet_subnet_id      = var.node_subnet_id
    pod_subnet_id       = var.pod_subnet_id
    tags                = var.azure_tags

    temporary_name_for_rotation = "tempnodepool"
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = var.service_cidr
    dns_service_ip = var.dns_service_ip
  }
}
