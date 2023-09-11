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

variable "bucket_location" {
  type        = string
  description = "GCS bucket location for source and sink buckets"
  default     = "US"
}

variable "cluster_name" {
  type        = string
  description = "Name to use for GKE cluster"
  default     = "gretel-cluster"
}

variable "firewall_policy_name" {
  type        = string
  description = "Name of firewall policy"
  default     = "gretel-fw-policy"
}

variable "master_authorized_ranges" {
  type        = map(string)
  description = "IP ranges with access to GKE control plane"
  default     = {"all-internet": "0.0.0.0/0"}
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "Range to use for control plane"
  default     = "192.168.0.0/28"
}

variable "nat_name" {
  type        = string
  description = "Name of Cloud NAT"
  default     = "gretel-nat"
}

variable "project_id" {
  type        = string
  description = "ID of GCP project in which cluster resources will be deployed"
}

variable "region" {
  type        = string
  description = "GCP region to use for cluster and associated networking resources"
}

variable "release_channel" {
  type        = string
  description = "Release channel to use for GKE cluster version upgrades"
  default     = "REGULAR"
}

variable "service_account_node_name" {
  type        = string
  description = "Name of node service account"
  default     = "gretel-node-sa"
}

variable "subnet_cidr_pods" {
  type        = string
  description = "CIDR for the secondary range to be associated with GKE pods"
  default     = "10.0.16.0/20"
}

variable "subnet_cidr_primary" {
  type        = string
  description = "Primary CIDR range to use for subnet (GKE node IPs are pulled from this range)"
  default     = "10.0.0.0/20"
}

variable "subnet_cidr_services" {
  type        = string
  description = "CIDR for the secondary range to be associated with GKE services"
  default     = "10.0.32.0/20"
}

variable "subnet_name" {
  type        = string
  description = "Name of the VPC subnet"
  default     = "gretel-vpc"
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
  default     = "gretel-subnet"
}

