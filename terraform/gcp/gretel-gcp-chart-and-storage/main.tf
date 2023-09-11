terraform {
  required_providers {
    kubernetes = "2.16.1"
    helm       = "2.8.0"
  }
}
data "google_client_config" "current" {}

data "google_container_cluster" "current" {
  project  = var.project_id
  name     = var.cluster_name
  location = var.region
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.current.endpoint}"
  cluster_ca_certificate = base64decode(data.google_container_cluster.current.master_auth[0].cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.current.endpoint}"
    cluster_ca_certificate = base64decode(data.google_container_cluster.current.master_auth[0].cluster_ca_certificate)
    token                  = data.google_client_config.current.access_token
  }
}

module "workload-service-account" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/iam-service-account?ref=v24.0.0"
  project_id = var.project_id
  name       = var.service_account_workload_name
}

module "gcs-bucket-source" {
  source        = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/gcs?ref=v24.0.0"
  project_id    = var.project_id
  name          = var.source_bucket_name
  location      = var.bucket_location
  versioning    = true
  force_destroy = true
  iam = {
    "roles/storage.admin" = ["serviceAccount:${module.workload-service-account.email}"]
  }
}

module "gcs-bucket-sink" {
  source        = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/gcs?ref=v24.0.0"
  project_id    = var.project_id
  name          = var.sink_bucket_name
  location      = var.bucket_location
  versioning    = true
  force_destroy = true
  iam = {
    "roles/storage.admin" = ["serviceAccount:${module.workload-service-account.email}"]
  }
}

resource "google_service_account_iam_binding" "service-account-iam" {
  service_account_id = module.workload-service-account.id
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.gretel_hybrid_namespace}/${var.gretel_agent_service_account}]",
  ]
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
      artifactEndpoint          = "gs://${var.sink_bucket_name}/",
      apiKey                    = var.gretel_api_key,
      apiEndpoint               = var.gretel_api_endpoint,
      gpuNodeSelector           = "{\"cloud.google.com/gke-accelerator\":\"nvidia-tesla-t4\"}",
      workerMemoryInGb          = var.gretel_worker_pod_memory_gb
      preventAutoscalerEviction = false
    }

    serviceAccount = {
      name = var.gretel_agent_service_account
      annotations = {
        "iam.gke.io/gcp-service-account" = module.workload-service-account.email
      }
    }
  })]
}
