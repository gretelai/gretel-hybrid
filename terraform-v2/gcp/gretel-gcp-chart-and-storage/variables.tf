variable "cluster_name" {
  type        = string
  description = "Name to use for GKE cluster"
  default     = "gretel-cluster"
}

variable "region" {
  type        = string
  description = "GCP region to use for cluster and associated networking resources"
}

variable "project_id" {
  type        = string
  description = "ID of GCP project in which storage resources will be deployed"
}

variable "sink_bucket_name" {
  type        = string
  description = "Unique name for sink GCS bucket"
}

variable "source_bucket_name" {
  type        = string
  description = "Unique name for source GCS bucket"
}

variable "bucket_location" {
  type        = string
  description = "GCS bucket location for source and sink buckets"
  default     = "US"
}

variable "service_account_workload_name" {
  type        = string
  description = "Name of workload service account"
  default     = "gretel-workload-sa"
}

variable "gretel_helm_repo" {
  type        = string
  description = "The gretel helm repository URL."
  default     = "https://gretel-blueprints-pub.s3.us-west-2.amazonaws.com/helm-charts/stable/"
}

variable "gretel_chart" {
  type        = string
  nullable    = false
  description = "The helm chart for gretel hybrid."
  default     = "gretel-data-plane"
}

variable "gretel_hybrid_namespace" {
  type        = string
  nullable    = false
  description = "The kubernetes namespace that gretel resources will be deployed in."
  default     = "gretel-hybrid"
}

variable "gretel_api_key" {
  type        = string
  nullable    = false
  description = "Key used to authenticate to the Gretel API."
  sensitive   = true
}

variable "gretel_api_endpoint" {
  type        = string
  nullable    = false
  description = "The Gretel API endpoint. This should almost always be the default: https://api.gretel.cloud"
  default     = "https://api.gretel.cloud"
}

variable "gretel_model_worker_pod_memory_gb" {
  type        = string
  description = "Memory request and limit for the model worker pods."
  default     = "14"
}
