module "cpu_node_group" {
  source = "./node_group"

  # Same for every node group
  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  cluster_endpoint               = var.cluster_endpoint
  cluster_auth_base64            = var.cluster_auth_base64
  cluster_node_security_group_id = var.cluster_node_security_group_id
  aws_tags                       = var.aws_tags

  # Set for each individual group
  name                 = var.cpu_node_group_config.name
  ami_base             = "amazon-eks-node"
  instance_type        = var.cpu_node_group_config.instance_type
  subnet_ids           = var.cpu_node_group_config.subnet_ids
  min_autoscaling_size = var.cpu_node_group_config.min_autoscaling_size
  max_autoscaling_size = var.cpu_node_group_config.max_autoscaling_size
  disk_size_gb         = var.cpu_node_group_config.disk_size_gb
  node_labels          = var.cpu_node_group_config.node_labels
  node_taints          = var.cpu_node_group_config.node_taints
}

module "gpu_node_group" {
  source = "./node_group"

  # Same for every node group
  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  cluster_endpoint               = var.cluster_endpoint
  cluster_auth_base64            = var.cluster_auth_base64
  cluster_node_security_group_id = var.cluster_node_security_group_id
  aws_tags                       = var.aws_tags

  # Set for each individual group
  name                 = var.gpu_node_group_config.name
  ami_base             = "amazon-eks-gpu-node"
  instance_type        = var.gpu_node_group_config.instance_type
  subnet_ids           = var.gpu_node_group_config.subnet_ids
  min_autoscaling_size = var.gpu_node_group_config.min_autoscaling_size
  max_autoscaling_size = var.gpu_node_group_config.max_autoscaling_size
  disk_size_gb         = var.gpu_node_group_config.disk_size_gb
  node_labels          = var.gpu_node_group_config.node_labels
  node_taints          = var.gpu_node_group_config.node_taints
}
