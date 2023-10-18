output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_intra_subnets" {
  value = module.vpc.intra_subnets
}

output "vpc_private_subnets" {
  value = module.vpc.private_subnets
}
