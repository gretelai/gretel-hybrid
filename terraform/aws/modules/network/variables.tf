variable "vpc_name" {
  type        = string
  description = "The name for the created VPC."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR for the VPC. eg. 10.0.0.0/16"
}

variable "vpc_private_subnet_cidrs" {
  type        = list(string)
  description = "A list of IP space for created private subnets."
}

variable "vpc_intra_subnet_cidrs" {
  type        = list(string)
  description = "A list of IP space for created intra subnets."
}

variable "vpc_public_subnet_cidrs" {
  type        = list(string)
  description = "A list of IP space for created public subnets."
}

variable "aws_tags" {
  description = "A map of tags to add to any created AWS resources."
  type        = map(any)
  default     = {}
}
