variable "cluster_name" {
  type = string
  description = "The EKS cluster name where aws-auth will be managed."
}

variable "worker_node_iam_role_arns" {
  type = list(string)
  description = "The list of node IAM role arns which will be granted proper access to the K8s API so that the nodes may join the cluster."
}

variable "cluster_admin_roles" {
  type    = map(string)
  default = {}
  description = "Optional list of IAM Role arns you would like added to the aws-auth ConfigMap with K8s admin permissions. Without specifying one of cluster_admin_roles or cluster_admin_users, the only IAM identity with access to the K8s cluster will be the cluster creator."
}

variable "cluster_admin_users" {
  type    = map(string)
  default = {}
  description = "Optional list of IAM User arns you would like added to the aws-auth ConfigMap with K8s admin permissions. Without specifying one of cluster_admin_roles or cluster_admin_users, the only IAM identity with access to the K8s cluster will be the cluster creator."
}
