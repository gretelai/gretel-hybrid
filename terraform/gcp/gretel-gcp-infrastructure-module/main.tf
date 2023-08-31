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

module "bastion-service-account" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/iam-service-account?ref=v24.0.0"
  project_id = var.project_id
  name       = var.service_account_bastion_name
  iam_project_roles = {
    "${var.project_id}" = [
      "roles/container.admin"
    ]
  }
}

module "workload-service-account" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/iam-service-account?ref=v24.0.0"
  project_id = var.project_id
  name       = var.service_account_workload_name
}

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

module "gcs-bucket-source" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/gcs?ref=v24.0.0"
  project_id = var.project_id
  name       = var.source_bucket_name
  location   = var.bucket_location
  versioning = true
  iam = {
    "roles/storage.admin" = ["serviceAccount:${module.workload-service-account.email}"]
  }
}

module "gcs-bucket-sink" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/gcs?ref=v24.0.0"
  project_id = var.project_id
  name       = var.sink_bucket_name
  location   = var.bucket_location
  versioning = true
  iam = {
    "roles/storage.admin" = ["serviceAccount:${module.workload-service-account.email}"]
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

module "compute-vpc-firewall-policy" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/net-vpc-firewall-policy?ref=v24.0.0"
  name       = var.firewall_policy_name
  project_id = var.project_id
  target_vpcs = {
    compute-host-vpc = module.vpc.self_link
  }
  ingress_rules = {
    allow-ingress-iap = {
      priority = 600
      action   = "allow"
      match = {
        source_ranges  = ["35.235.240.0/20"]
        layer4_configs = [{ protocol = "tcp", ports = [22] }]
      }
    }
  }
}

module "vm-bastion" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/compute-vm?ref=v24.0.0"
  project_id = var.project_id
  zone       = "${var.region}-a"
  name       = "bastion"
  network_interfaces = [{
    network    = module.vpc.self_link
    subnetwork = lookup(module.vpc.subnet_self_links, "${var.region}/${var.subnet_name}", null)
    # won't this block kubectl install?
    nat       = false
    addresses = null
  }]
  tags = ["ssh"]
  metadata = {
    startup-script = join("\n", [
      "#! /bin/bash",
      "curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null",
      "sudo apt-get install apt-transport-https --yes",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main\" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list",
      "apt-get update",
      "apt-get install helm",
      "apt-get install -y kubectl google-cloud-sdk-gke-gcloud-auth-plugin pip",
      "pip install -U smart_open[gcs] gretel-client"
    ])
  }
  service_account_create = false
  service_account        = module.bastion-service-account.email
  service_account_scopes = ["cloud-platform"]
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
  private_cluster_config = {
    enable_private_endpoint = var.enable_private_endpoint
    master_global_access    = var.master_global_access
  }
  service_account = module.node-service-account.email
  enable_features = {
    dns = {
      provider = "CLOUD_DNS"
      scope    = "CLUSTER_SCOPE"
      domain   = "cluster.local"
    }
  }
}
