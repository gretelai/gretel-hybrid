module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = var.project_id
  name                       = var.cluster_name
  region                     = var.location
  kubernetes_version         = var.gke_version
  network                    = var.network_name
  subnetwork                 = var.subnet_name
  ip_range_pods              = var.ip_range_name_pods
  ip_range_services          = var.ip_range_name_services
  http_load_balancing        = false
  horizontal_pod_autoscaling = false
  deletion_protection        = var.cluster_prevent_destroy

  node_pools = [
    {
      name         = "default-node-pool"
      machine_type = var.default_node_group_config.machine_type
      min_count    = var.default_node_group_config.min_autoscaling_size
      max_count    = var.default_node_group_config.max_autoscaling_size
      disk_size_gb = var.default_node_group_config.disk_size_gb
      disk_type    = "pd-balanced"
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}
