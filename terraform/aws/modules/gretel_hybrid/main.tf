# Formatting tolerations to match helm chart's expected input
locals {
  gpu_tolerations = [
    for toleration in var.gretel_gpu_model_worker_tolerations : {
      key      = toleration.key
      operator = "Equal"
      value    = toleration.value
      effect   = toleration.effect
    }
  ]
  cpu_tolerations = [
    for toleration in var.gretel_cpu_model_worker_tolerations : {
      key      = toleration.key
      operator = "Equal"
      value    = toleration.value
      effect   = toleration.effect
    }
  ]
}

resource "aws_s3_bucket" "gretel_hybrid_source_bucket" {
  bucket = var.gretel_source_bucket_name
  tags   = var.aws_tags
}

resource "aws_s3_bucket" "gretel_hybrid_sink_bucket" {
  bucket = var.gretel_sink_bucket_name
  tags   = var.aws_tags
}

resource "aws_iam_policy" "gretel_hybrid_agent_iam_policy" {
  name        = var.gretel_agent_iam_policy_name
  description = "The IAM policy required for the Gretel Hybrid Agent to access necessary resources."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          "${aws_s3_bucket.gretel_hybrid_source_bucket.arn}",
          "${aws_s3_bucket.gretel_hybrid_source_bucket.arn}/*",
          "${aws_s3_bucket.gretel_hybrid_sink_bucket.arn}",
          "${aws_s3_bucket.gretel_hybrid_sink_bucket.arn}/*"
        ]
      },
    ]
  })
}

module "gretel_hybrid_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = var.gretel_agent_iam_role_name

  role_policy_arns = {
    policy = aws_iam_policy.gretel_hybrid_agent_iam_policy.arn
  }

  oidc_providers = {
    cluster_1 = {
      provider_arn               = var.cluster_oidc_provider_arn
      namespace_service_accounts = ["${var.gretel_hybrid_namespace}:${var.gretel_agent_service_account}"]
    }
  }
}

resource "kubernetes_namespace" "gretel_hybrid_namespace" {
  metadata {
    name = var.gretel_hybrid_namespace
  }
}

resource "helm_release" "gretel_hybrid_agent" {
  name       = "gretel-agent"
  repository = var.gretel_helm_repo
  chart      = var.gretel_chart
  namespace  = var.gretel_hybrid_namespace
  depends_on = [
    kubernetes_namespace.gretel_hybrid_namespace
  ]

  values = [yamlencode({
    gretelConfig = {
      artifactEndpoint          = "s3://${aws_s3_bucket.gretel_hybrid_sink_bucket.id}/",
      project                   = var.gretel_hybrid_project,
      apiKey                    = var.gretel_api_key,
      apiEndpoint               = var.gretel_api_endpoint,
      workerMemoryInGb          = var.gretel_worker_pod_memory_gb,
      cpuCount                  = var.gretel_worker_pod_cpu_count,
      maxWorkers                = var.gretel_max_workers,
      gpuNodeSelector           = var.gretel_gpu_worker_node_selector,
      gpuTolerations            = local.gpu_tolerations,
      cpuNodeSelector           = var.gretel_cpu_model_worker_node_selector,
      cpuTolerations            = local.cpu_tolerations,
      imageRegistryOverrideHost = var.gretel_image_registry_override_host
    }

    serviceAccount = {
      annotations = {
        "eks.amazonaws.com/role-arn" = module.gretel_hybrid_irsa_role.iam_role_arn
      }
    }
  })]
}
