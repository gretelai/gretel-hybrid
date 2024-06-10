locals {
  labels_string_list = [
    for label in var.node_labels : "${label.key}=${label.value}"
  ]
  taints_string_list = [
    for taint in var.node_taints : "${taint.key}=${taint.value}:${taint.effect}"
  ]
  node_labels = format("--node-labels=%s", join(",", local.labels_string_list))
  node_taints = format("--register-with-taints=%s", join(",", local.taints_string_list))


  # Setting up ASG tags for cluster-autoscaler
  cluster_autoscaler_label_tags = {
    for label in var.node_labels :
    "k8s.io/cluster-autoscaler/node-template/label/${label.key}" => "${label.value}"
  }
  cluster_autoscaler_taint_tags = {
    for taint in var.node_taints :
    "k8s.io/cluster-autoscaler/node-template/taint/${taint.key}" => "${taint.value}:${taint.effect}"
  }
  cluster_autoscaler_resource_tags = {
    for resource in var.node_resource_hints :
    "k8s.io/cluster-autoscaler/node-template/resources/${resource.key}" => "${resource.value}"
  }

  cluster_autoscaler_asg_tags = merge(local.cluster_autoscaler_label_tags, local.cluster_autoscaler_taint_tags, local.cluster_autoscaler_resource_tags)

  k8s_tags = merge({
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
    "k8s.io/cluster-autoscaler/enabled"             = "true"
  }, local.cluster_autoscaler_asg_tags)
}

data "aws_ami" "node_group_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["${var.ami_base}-${var.cluster_version}-v*"]
  }
}

resource "aws_iam_policy" "node_group_iam_policy" {
  name        = "${var.cluster_name}-${var.name}-iam-policy"
  description = "Custom IAM policy for the EKS node group: ${var.name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "autoscaling:DescribeAutoScalingInstances",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

module "node_group" {
  source  = "terraform-aws-modules/eks/aws//modules/self-managed-node-group"
  version = "~> 19.16.0"

  name                = var.name
  cluster_name        = var.cluster_name
  cluster_version     = var.cluster_version
  cluster_endpoint    = var.cluster_endpoint
  cluster_auth_base64 = var.cluster_auth_base64

  instance_type = var.instance_type
  min_size      = var.min_autoscaling_size
  max_size      = var.max_autoscaling_size
  ami_id        = data.aws_ami.node_group_ami.image_id
  subnet_ids    = var.subnet_ids
  vpc_security_group_ids = [
    var.cluster_node_security_group_id
  ]
  launch_template_name   = "${var.name}-lt"
  autoscaling_group_tags = local.k8s_tags

  iam_role_additional_policies = {
    AmazonSSMManagedEC2InstanceDefaultPolicy = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
    CloudWatchAgentServerPolicy              = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    WorkerNodeBootstrapPolicy                = aws_iam_policy.node_group_iam_policy.arn
  }

  bootstrap_extra_args = "--kubelet-extra-args '${local.node_labels} ${local.node_taints}'"


  block_device_mappings = {
    root_volume = {
      device_name = "/dev/xvda"
      ebs = {
        volume_size           = var.disk_size_gb
        volume_type           = "gp3"
        delete_on_termination = true
        encrypted             = true
      }
    }
  }
  network_interfaces = [{
    associate_public_ip_address = false
    delete_on_termination       = true
  }]

  tags = var.aws_tags
}
