/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# terraform {
#   backend "gcs" {
#     bucket = "gretelai-terraform-remote-state" # Can't use variable in backend spec
#     prefix = "state"
#   }
# }

module "project" {
  source          = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project?ref=v24.0.0"
  billing_account = var.billing_account
  name            = var.project_id
  parent          = var.parent
  services = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "iap.googleapis.com"
  ]
}

# The gcloud module is used here due to limitations in the provider resource. Use of the gcloud module is not recommended in general. 
module "gcloud-enable-serial-port-logging" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 2.0"

  platform              = var.gcloud_platform
  additional_components = []

  create_cmd_entrypoint  = "gcloud"
  create_cmd_body        = "compute project-info add-metadata --metadata serial-port-logging-enable=true --project ${module.project.project_id}"
  destroy_cmd_entrypoint = "gcloud"
  destroy_cmd_body       = "compute project-info remove-metadata --keys=serial-port-logging-enable --project ${module.project.project_id}"

  module_depends_on = [module.project.project_id]
}

module "gcs-bucket-terraform-state" {
  source        = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/gcs?ref=v24.0.0"
  project_id    = module.project.id
  name          = var.remote_state_bucket_name
  location      = var.remote_state_bucket_location
  versioning    = true
  force_destroy = true
}

module "gretel-infrastructure" {
  source       = "../../gcp"
  project_id   = module.project.id
  region       = var.region
  cluster_name = var.cluster_name
}

