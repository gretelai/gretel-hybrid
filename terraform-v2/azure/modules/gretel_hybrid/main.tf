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
    for toleration in var.gretel_gpu_model_worker_tolerations : {
      key      = toleration.key
      operator = "Equal"
      value    = toleration.value
      effect   = toleration.effect
    }
  ]
  cpu_tolerations = [
    for toleration in var.gretel_cpu_model_worker_tolerations : {
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


resource "azurerm_storage_management_policy" "expire_objects_policy" {
  storage_account_id = azurerm_storage_account.gretel_hybrid.id

  rule {
    name    = "expire-scratch-objects"
    enabled = true
    filters {
      prefix_match = ["workflowruns/scratch/"]
      blob_types   = ["blockBlob", "appendBlob"]
    }
    actions {
      base_blob {
        delete_after_days_since_creation_greater_than = 7
      }
      snapshot {
        delete_after_days_since_creation_greater_than = 7
      }
      version {
        delete_after_days_since_creation = 7
      }
    }
  }
}

resource "kubernetes_namespace" "gretel_hybrid_namespace" {
  metadata {
    name = var.gretel_hybrid_namespace
  }
}

// Key Vault and Key
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "gretel_key_vault" {
  name                = var.gretel_key_vault_name
  location            = var.existing_resource_group_region
  resource_group_name = var.existing_resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

resource "azurerm_key_vault_key" "gretel_key" {
  name         = var.gretel_key_vault_key_name
  key_vault_id = azurerm_key_vault.gretel_key_vault.id
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [
    azurerm_key_vault_access_policy.current_user_access
  ]
}


// Managed Users
resource "azurerm_user_assigned_identity" "gretel_workflow_worker" {
  name                = var.gretel_workflow_worker_service_account
  resource_group_name = var.existing_resource_group_name
  location            = var.existing_resource_group_region
}

resource "azurerm_key_vault_access_policy" "gretel_workflow_worker" {
  key_vault_id = azurerm_key_vault.gretel_key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.gretel_workflow_worker.principal_id

  key_permissions = [
    "Get", "List", "Encrypt", "Decrypt"
  ]
}

resource "azurerm_user_assigned_identity" "gretel_model_worker" {
  name                = var.gretel_model_worker_service_account
  resource_group_name = var.existing_resource_group_name
  location            = var.existing_resource_group_region
}

// Required to be able to validate the keys are set
// As well as run encryption operations for connections
resource "azurerm_key_vault_access_policy" "current_user_access" {
  key_vault_id = azurerm_key_vault.gretel_key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.keyvault_user_access_object_id == null ? data.azurerm_client_config.current.object_id : var.keyvault_user_access_object_id

  key_permissions = ["Encrypt", "Decrypt", "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "Purge", "GetRotationPolicy", "SetRotationPolicy"]
}


resource "azurerm_role_assignment" "gretel_workflow_worker_blob_contributor" {
  scope = azurerm_storage_account.gretel_hybrid.id

  # using azure defined role
  role_definition_name = "Storage Blob Data Contributor"

  principal_id = azurerm_user_assigned_identity.gretel_workflow_worker.principal_id
}

resource "azurerm_role_assignment" "gretel_model_worker_blob_contributor" {
  scope = azurerm_storage_account.gretel_hybrid.id

  # using azure defined role
  role_definition_name = "Storage Blob Data Contributor"

  principal_id = azurerm_user_assigned_identity.gretel_model_worker.principal_id
}

resource "azurerm_federated_identity_credential" "gretel_workflow_worker" {
  name                = var.gretel_workflow_worker_service_account
  resource_group_name = var.existing_resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.kubernetes_oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.gretel_workflow_worker.id
  subject             = "system:serviceaccount:${var.gretel_hybrid_namespace}:${var.gretel_workflow_worker_service_account}"
}

resource "azurerm_federated_identity_credential" "gretel_model_worker" {
  name                = var.gretel_model_worker_service_account
  resource_group_name = var.existing_resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.kubernetes_oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.gretel_model_worker.id
  subject             = "system:serviceaccount:${var.gretel_hybrid_namespace}:${var.gretel_model_worker_service_account}"
}

resource "helm_release" "gretel_hybrid_agent" {
  count      = var.skip_kubernetes_resources ? 0 : 1
  name       = "gretel-agent"
  repository = var.gretel_helm_repo
  chart      = var.gretel_chart
  namespace  = var.gretel_hybrid_namespace
  depends_on = [
    kubernetes_namespace.gretel_hybrid_namespace
  ]

  values = [yamlencode({
    gretelConfig = {
      apiEndpoint      = var.gretel_api_endpoint
      apiKey           = var.gretel_api_key
      projects         = var.gretel_hybrid_projects
      artifactEndpoint = "azure://${azurerm_storage_container.sink.name}/",
    }

    gretelWorkers = {
      env = {
        AZURE_STORAGE_ACCOUNT_NAME = azurerm_storage_account.gretel_hybrid.name
      }

      podLabels = {
        "azure.workload.identity/use" = "true"
      }

      images = {
        registry = var.gretel_image_registry_override_host
      }

      workflow = {
        serviceAccount = {
          name = var.gretel_workflow_worker_service_account
          annotations = {
            "azure.workload.identity/client-id" = azurerm_user_assigned_identity.gretel_workflow_worker.client_id
          }
        }
      }

      model = {
        maxConcurrent = var.gretel_max_workers
        serviceAccount = {
          name = var.gretel_model_worker_service_account
          annotations = {
            "azure.workload.identity/client-id" = azurerm_user_assigned_identity.gretel_model_worker.client_id
          }
        }

        resources = {
          requests = {
            cpu    = var.gretel_model_worker_pod_cpu_count
            memory = "${var.gretel_model_worker_pod_memory_gb}Gi"
          }
          limits = {
            memory = "${var.gretel_model_worker_pod_memory_gb}Gi"
          }
        }
        cpu = {
          nodeSelector = var.gretel_cpu_model_worker_node_selector
          tolerations  = local.cpu_tolerations
        }
        gpu = {
          nodeSelector = var.gretel_gpu_model_worker_node_selector
          tolerations  = local.gpu_tolerations
        }
      }
    }
    }),
    yamlencode(var.extra_helm_values),
  ]
}
