terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "<5.29.0" # https://github.com/hashicorp/terraform-provider-google/issues/18115
    }
  }
}

locals {
  ip_range_name_pods     = "pods"
  ip_range_name_services = "services"
}

module "vpc" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/net-vpc?ref=v24.0.0"
  project_id = var.project_id
  name       = var.vpc_name
  subnets = [
    {
      ip_cidr_range = var.subnet_cidr_primary
      name          = var.subnet_name
      region        = var.location
      secondary_ip_ranges = {
        (local.ip_range_name_pods)     = var.subnet_cidr_pods
        (local.ip_range_name_services) = var.subnet_cidr_services
      }
    }
  ]
}

module "nat" {
  source         = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/net-cloudnat?ref=v24.0.0"
  project_id     = var.project_id
  region         = var.location
  name           = var.nat_name
  router_name    = "${var.nat_name}-router"
  router_network = module.vpc.self_link
  router_create  = true
}
