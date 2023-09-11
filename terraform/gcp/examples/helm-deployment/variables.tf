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

variable "project_id" {
  type        = string
  description = "ID of GCP project in which cluster resources will be deployed"
}

variable "gcloud_platform" {
  type        = string
  description = "The platform on which gcloud is being run, i.e. 'linux' or 'darwin'"
}

variable "region" {
  type        = string
  description = "GCP region to use for cluster and associated networking resources"
}

variable "cluster_name" {
  type        = string
  description = "Name to use for GKE cluster"
  default     = "gretel-cluster"
}

variable "sink_bucket_name" {
  type        = string
  description = "Unique name for sink GCS bucket"
}

variable "source_bucket_name" {
  type        = string
  description = "Unique name for source GCS bucket"
}

variable "terraform_service_account" {
  type        = string
  description = "Service account to assume during terraform plan/applies"
}

variable "gretel_api_key" {
  type        = string
  description = "API Key used to authenticate with Gretel's APIs"
}
