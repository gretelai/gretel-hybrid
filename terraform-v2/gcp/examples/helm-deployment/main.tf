# terraform {
#   backend "gcs" {
#     bucket = "gretelai-terraform-remote-state" # Can't use variable in backend spec
#     prefix = "helm-state"
#   }
# }


module "chart_and_storage" {
  source             = "../../gretel-gcp-chart-and-storage"
  cluster_name       = var.cluster_name
  gretel_api_key     = var.gretel_api_key
  region             = var.region
  source_bucket_name = var.source_bucket_name
  sink_bucket_name   = var.sink_bucket_name
  project_id         = var.project_id
}
