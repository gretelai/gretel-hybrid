variable "project_id" {
  type        = string
  description = "ID of GCP project in which cluster resources will be deployed"
}

variable "location" {
  type        = string
  nullable    = false
  description = "The GCP location/region to deploy resources into."
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
  default     = "gretel-subnet"
}

variable "subnet_name" {
  type        = string
  description = "Name of the VPC subnet"
  default     = "gretel-vpc"
}

variable "subnet_cidr_primary" {
  type        = string
  description = "Primary CIDR range to use for subnet (GKE node IPs are pulled from this range)"
  default     = "10.0.0.0/20"
}

variable "subnet_cidr_pods" {
  type        = string
  description = "CIDR for the secondary range to be associated with GKE pods"
  default     = "10.0.16.0/20"
}

variable "subnet_cidr_services" {
  type        = string
  description = "CIDR for the secondary range to be associated with GKE services"
  default     = "10.0.32.0/20"
}

variable "nat_name" {
  type        = string
  description = "Name of Cloud NAT"
  default     = "gretel-nat"
}
