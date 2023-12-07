data "aws_caller_identity" "current" {}

locals {
  roles = concat(
    [
      for u, arn in var.cluster_admin_roles :
      {
        username = u
        rolearn  = arn
        groups   = ["system:masters"]
      }
    ],
    [for role_arn in var.worker_node_iam_role_arns : {
      rolearn  = role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
      }
    ]
  )

  users = concat(
    [
      for u, arn in var.cluster_admin_users :
      {
        username = u
        userarn  = arn
        groups   = ["system:masters"]

      }
    ]
  )

  accounts = [
    data.aws_caller_identity.current.account_id
  ]

  configmap = {
    mapRoles    = yamlencode(local.roles)
    mapUsers    = yamlencode(local.users)
    mapAccounts = yamlencode(local.accounts)
  }
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  force = true
  # Prod use cases should uncomment this.
  # lifecycle {
  #   prevent_destroy = true
  # }

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.configmap
}
