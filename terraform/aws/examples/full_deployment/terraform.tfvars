region                    = "us-west-2"
deployment_name           = "gretel-hybrid-env"
kubernetes_version        = "1.27"
gretel_source_bucket_name = "gretel-hybrid-source"
gretel_sink_bucket_name   = "gretel-hybrid-sink"
# Provide any IAM users or roles which should be allowed to run "aws eks update-kubeconfig" to gain access to the cluster
cluster_admin_roles = {
  # Format: "<name_for_kubernetes_rbac>" = "<iam_role_arn>"
  # Example: "adminrole" = "arn:aws:iam::012345678912:role/cloud_team_admin_role"
}
cluster_admin_users = {
  # Format: "<name_for_kubernetes_rbac>" = "<iam_user_arn>"
  # Example: "poweruser" = "arn:aws:iam::012345678912:user/cloud_team_admin_role"
}
