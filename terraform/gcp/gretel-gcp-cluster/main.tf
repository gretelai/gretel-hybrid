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

module "node-service-account" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/iam-service-account?ref=v24.0.0"
  project_id = var.project_id
  name       = var.service_account_node_name
  iam_project_roles = {
    "${var.project_id}" = [
      "roles/container.nodeServiceAccount",
      "roles/artifactregistry.reader"
    ]
  }
}

module "vpc" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/net-vpc?ref=v24.0.0"
  project_id = var.project_id
  name       = var.vpc_name
  subnets = [
    {
      ip_cidr_range = var.subnet_cidr_primary
      name          = var.subnet_name
      region        = var.region
      secondary_ip_ranges = {
        pods     = var.subnet_cidr_pods
        services = var.subnet_cidr_services
      }
    }
  ]
}

module "nat" {
  source         = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/net-cloudnat?ref=v24.0.0"
  project_id     = var.project_id
  region         = var.region
  name           = var.nat_name
  router_name    = "${var.nat_name}-router"
  router_network = module.vpc.self_link
  router_create  = true
}

module "cluster" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/gke-cluster-autopilot?ref=v24.0.0"
  project_id = var.project_id
  name       = var.cluster_name
  location   = var.region
  vpc_config = {
    network                  = module.vpc.self_link
    subnetwork               = module.vpc.subnet_self_links["${var.region}/${var.subnet_name}"]
    master_authorized_ranges = var.master_authorized_ranges
    master_ipv4_cidr_block   = var.master_ipv4_cidr_block
  }
  release_channel = var.release_channel
  service_account = module.node-service-account.email
  enable_features = {
    dns = {
      provider = "CLOUD_DNS"
      scope    = "CLUSTER_SCOPE"
      domain   = "cluster.local"
    }
  }
}
