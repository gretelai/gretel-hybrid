terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

locals {
  gpu_tolerations = [
    for toleration in var.gretel_gpu_worker_tolerations : {
      key      = toleration.key
      operator = "Equal"
      value    = toleration.value
      effect   = toleration.effect
    }
  ]
  cpu_tolerations = [
    for toleration in var.gretel_cpu_worker_tolerations : {
      key      = toleration.key
      operator = "Equal"
      value    = toleration.value
      effect   = toleration.effect
    }
  ]
}

resource "azurerm_storage_account" "gretel_hybrid" {
  resource_group_name      = var.existing_resource_group_name
  location                 = var.existing_resource_group_region
  name                     = var.gretel_storage_account_name
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags                     = var.azure_tags
}

resource "azurerm_storage_container" "source" {
  name                 = var.gretel_source_storage_container_name
  storage_account_name = azurerm_storage_account.gretel_hybrid.name
}

resource "azurerm_storage_container" "sink" {
  name                 = var.gretel_sink_storage_container_name
  storage_account_name = azurerm_storage_account.gretel_hybrid.name
}

resource "kubernetes_namespace" "gretel_hybrid_namespace" {
  metadata {
    name = var.gretel_hybrid_namespace
  }
}

resource "helm_release" "gretel_hybrid_agent" {
  name       = "gretel-agent"
  repository = var.gretel_helm_repo
  chart      = var.gretel_chart
  namespace  = var.gretel_hybrid_namespace
  depends_on = [
    kubernetes_namespace.gretel_hybrid_namespace
  ]

  values = [yamlencode({
    gretelConfig = {
      artifactEndpoint          = "azure://${azurerm_storage_container.sink.name}/",
      project                   = var.gretel_hybrid_project,
      apiKey                    = var.gretel_api_key,
      apiEndpoint               = var.gretel_api_endpoint,
      workerMemoryInGb          = var.gretel_worker_pod_memory_gb,
      cpuCount                  = var.gretel_worker_pod_cpu_count,
      maxWorkers                = var.gretel_max_workers,
      gpuNodeSelector           = var.gretel_gpu_worker_node_selector,
      gpuTolerations            = local.gpu_tolerations,
      cpuNodeSelector           = var.gretel_cpu_worker_node_selector,
      cpuTolerations            = local.cpu_tolerations,
      imageRegistryOverrideHost = var.gretel_image_registry_override_host,
      workerEnv = {
        AZURE_STORAGE_CONNECTION_STRING = azurerm_storage_account.gretel_hybrid.primary_connection_string
      }
    }
  })]
}
