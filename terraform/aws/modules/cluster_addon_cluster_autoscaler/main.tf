locals {
  name                               = var.cluster_name
  cluster_oidc_provider_arn          = var.cluster_oidc_provider_arn
  cluster_autoscaler_iam_role_name   = var.cluster_autoscaler_iam_role_name
  cluster_autoscaler_namespace       = var.cluster_autoscaler_namespace
  cluster_autoscaler_service_account = var.cluster_autoscaler_service_account
  cluster_autoscaler_chart_version   = var.cluster_autoscaler_chart_version
  cluster_autoscaler_version         = var.cluster_autoscaler_version
  tags                               = var.aws_tags
}

data "aws_region" "current" {}

module "cluster_autoscaler_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                        = local.cluster_autoscaler_iam_role_name
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [local.name]

  oidc_providers = {
    cluster_1 = {
      provider_arn               = local.cluster_oidc_provider_arn
      namespace_service_accounts = ["${local.cluster_autoscaler_namespace}:${local.cluster_autoscaler_service_account}"]
    }
  }

  tags = local.tags
}

resource "helm_release" "cluster_autoscaler_chart" {
  name             = "autoscaler"
  repository       = "https://kubernetes.github.io/autoscaler"
  chart            = "cluster-autoscaler"
  namespace        = local.cluster_autoscaler_namespace
  create_namespace = true
  version          = local.cluster_autoscaler_chart_version

  set {
    name  = "image.tag"
    value = local.cluster_autoscaler_version
  }

  set {
    name  = "awsRegion"
    value = data.aws_region.current.name
  }

  set {
    name  = "autoDiscovery.clusterName"
    value = local.name
  }

  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }

  set {
    name  = "rbac.create"
    value = "true"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = local.cluster_autoscaler_service_account
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.cluster_autoscaler_irsa_role.iam_role_arn
  }

  set {
    name  = "extraArgs.expander"
    value = "most-pods"
  }

  // See https://github.com/hashicorp/terraform-provider-helm/issues/669
  values = [
    yamlencode({
      resources = {
        limits = {
          memory = "300Mi"
        }
        requests = {
          cpu    = "100m"
          memory = "300Mi"
        }
      }
    })
  ]
}
