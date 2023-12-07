locals {
  # Hacky way to convert properly defined k8s taints to the casing that google_container_node_pool needs
  formatted_taints_cpu = [
    for taint in var.cpu_node_group_config.node_taints :
    {
      key    = taint.key
      value  = taint.value
      effect = lookup({ "NoSchedule" = "NO_SCHEDULE", "PreferNoSchedule" = "PREFER_NO_SCHEDULE" }, taint.effect, "NO_SCHEDULE")
    }
  ]
  formatted_taints_gpu = [
    for taint in var.gpu_node_group_config.node_taints :
    {
      key    = taint.key
      value  = taint.value
      effect = lookup({ "NoSchedule" = "NO_SCHEDULE", "PreferNoSchedule" = "PREFER_NO_SCHEDULE" }, taint.effect, "NO_SCHEDULE")
    }
  ]
}

module "node_service_account" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/iam-service-account?ref=v24.0.0"
  project_id = var.project_id
  name       = var.iam_service_account_name
  iam_project_roles = {
    "${var.project_id}" = [
      "roles/container.nodeServiceAccount",
      "roles/artifactregistry.reader"
    ]
  }
}

resource "google_container_node_pool" "cpu_node_pool" {
  location       = var.location
  project        = var.project_id
  cluster        = var.cluster_name
  name           = var.cpu_node_group_config.name
  node_locations = var.cpu_node_group_config.node_locations

  network_config {
    pod_range = var.cpu_node_group_config.ip_range_name_pods
  }

  autoscaling {
    total_min_node_count = var.cpu_node_group_config.min_autoscaling_size
    total_max_node_count = var.cpu_node_group_config.max_autoscaling_size
  }

  node_config {
    machine_type    = var.cpu_node_group_config.machine_type
    disk_size_gb    = var.cpu_node_group_config.disk_size_gb
    disk_type       = "pd-balanced"
    service_account = module.node_service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      for label in var.cpu_node_group_config.node_labels : label.key => label.value
    }
    dynamic "taint" {
      for_each = local.formatted_taints_cpu
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }
  }
}

resource "google_container_node_pool" "gpu_node_pool" {
  location       = var.location
  project        = var.project_id
  cluster        = var.cluster_name
  name           = var.gpu_node_group_config.name
  node_locations = var.gpu_node_group_config.node_locations

  network_config {
    pod_range = var.gpu_node_group_config.ip_range_name_pods
  }

  autoscaling {
    total_min_node_count = var.gpu_node_group_config.min_autoscaling_size
    total_max_node_count = var.gpu_node_group_config.max_autoscaling_size
  }

  node_config {
    machine_type    = var.gpu_node_group_config.machine_type
    disk_size_gb    = var.gpu_node_group_config.disk_size_gb
    disk_type       = "pd-balanced"
    service_account = module.node_service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    guest_accelerator {
      type  = var.gpu_node_group_config.gpu_type
      count = var.gpu_node_group_config.gpu_count
      gpu_driver_installation_config {
        gpu_driver_version = "LATEST"
      }
    }

    labels = {
      for label in var.gpu_node_group_config.node_labels : label.key => label.value
    }
    dynamic "taint" {
      for_each = local.formatted_taints_gpu
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }
  }
}
