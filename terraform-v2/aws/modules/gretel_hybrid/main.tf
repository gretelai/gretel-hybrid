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

resource "aws_s3_bucket_lifecycle_configuration" "gretel_hybrid_sink_lifecycle_config" {
  bucket = aws_s3_bucket.gretel_hybrid_sink_bucket.id

  rule {
    id     = "incomplete-multipart"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }

  rule {
    id     = "expire-scratch-objects"
    status = "Enabled"

    expiration {
      days = 7
    }

    filter {
      prefix = "workflowruns/scratch/"
    }
  }
}

data "aws_iam_policy_document" "credentials_encryption_key_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
  statement {
    sid    = "Enable encryption by additional users"
    effect = "Allow"
    principals {
      type = "AWS"
      # Having an empty list here is an error, so we just repeat the root account such that
      # we are guaranteed to have a non-empty list.
      identifiers = concat(["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"], var.gretel_credentials_encryption_key_user_arns)
    }
    actions   = ["kms:Encrypt"]
    resources = ["*"]
  }
}

resource "aws_kms_key" "credentials_encryption_key" {
  key_usage   = "ENCRYPT_DECRYPT"
  description = "KMS key for encryption connection credentials"
  tags        = var.aws_tags
  policy      = data.aws_iam_policy_document.credentials_encryption_key_policy.json
}

resource "aws_kms_alias" "credentials_encryption_key_alias" {
  name          = "alias/${var.gretel_credentials_encryption_key_alias}"
  target_key_id = aws_kms_key.credentials_encryption_key.key_id
}

resource "aws_kms_key" "asymmetric_credentials_encryption_key" {
  key_usage                = "ENCRYPT_DECRYPT"
  description              = "KMS key for asymmetric encryption of connection credentials"
  customer_master_key_spec = "RSA_4096"
  policy                   = data.aws_iam_policy_document.credentials_encryption_key_policy.json
  count                    = var._enable_asymmetric_encryption ? 1 : 0
}

data "aws_kms_public_key" "asymmetric_credentials_encryption_public_key" {
  key_id = aws_kms_key.asymmetric_credentials_encryption_key[0].key_id
  count  = var._enable_asymmetric_encryption ? 1 : 0
}

data "aws_iam_policy_document" "read_from_source_bucket" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectVersion",
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.gretel_hybrid_source_bucket.arn}",
      "${aws_s3_bucket.gretel_hybrid_source_bucket.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "edit_sink_bucket" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:DeleteObject",
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.gretel_hybrid_sink_bucket.arn}",
      "${aws_s3_bucket.gretel_hybrid_sink_bucket.arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "decrypt_credentials" {
  statement {
    actions = [
      "kms:Decrypt",
    ]
    effect = "Allow"
    resources = concat(
      [aws_kms_key.credentials_encryption_key.arn],
      [for k in aws_kms_key.asymmetric_credentials_encryption_key : k.arn],
    )
  }
}

data "aws_iam_policy_document" "gretel_workflow_worker_iam_policy_document" {
  source_policy_documents = compact([
    data.aws_iam_policy_document.edit_sink_bucket.json,
    data.aws_iam_policy_document.decrypt_credentials.json,
  ])
}

resource "aws_iam_policy" "gretel_workflow_worker_iam_policy" {
  name        = var.gretel_workflow_worker_iam_policy_name
  description = "The IAM policy required for Gretel Hybrid workflow workers to access necessary resources."

  policy = data.aws_iam_policy_document.gretel_workflow_worker_iam_policy_document.json
}

module "gretel_workflow_worker_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.30.0"

  role_name = var.gretel_workflow_worker_iam_role_name

  role_policy_arns = {
    policy = aws_iam_policy.gretel_workflow_worker_iam_policy.arn
  }

  oidc_providers = {
    cluster_1 = {
      provider_arn               = var.cluster_oidc_provider_arn
      namespace_service_accounts = ["${var.gretel_hybrid_namespace}:${var.gretel_workflow_worker_service_account}"]
    }
  }
}

data "aws_iam_policy_document" "gretel_model_worker_iam_policy_document" {
  source_policy_documents = compact([
    data.aws_iam_policy_document.read_from_source_bucket.json,
    data.aws_iam_policy_document.edit_sink_bucket.json,
  ])
}

resource "aws_iam_policy" "gretel_model_worker_iam_policy" {
  name        = var.gretel_model_worker_iam_policy_name
  description = "The IAM policy required for Gretel Hybrid model workers to access necessary resources."

  policy = data.aws_iam_policy_document.gretel_model_worker_iam_policy_document.json
}

module "gretel_model_worker_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.30.0"

  role_name = var.gretel_model_worker_iam_role_name

  role_policy_arns = {
    policy = aws_iam_policy.gretel_model_worker_iam_policy.arn
  }

  oidc_providers = {
    cluster_1 = {
      provider_arn               = var.cluster_oidc_provider_arn
      namespace_service_accounts = ["${var.gretel_hybrid_namespace}:${var.gretel_model_worker_service_account}"]
    }
  }
}

resource "kubernetes_namespace" "gretel_hybrid_namespace" {
  count = var.skip_kubernetes_resources ? 0 : 1
  metadata {
    name = var.gretel_hybrid_namespace
  }
}

resource "helm_release" "gretel_hybrid_agent" {
  count      = var.skip_kubernetes_resources ? 0 : 1
  name       = "gretel-agent"
  repository = var.gretel_helm_repo
  chart      = var.gretel_chart
  namespace  = var.gretel_hybrid_namespace
  depends_on = [
    kubernetes_namespace.gretel_hybrid_namespace
  ]

  values = [
    yamlencode({
      gretelConfig = {
        apiEndpoint      = var.gretel_api_endpoint
        apiKey           = var.gretel_api_key
        artifactEndpoint = "s3://${aws_s3_bucket.gretel_hybrid_sink_bucket.id}/"
        artifactRegion   = aws_s3_bucket.gretel_hybrid_sink_bucket.region
        projects         = var.gretel_hybrid_projects
        asymmetricEncryption = var._enable_asymmetric_encryption ? {
          keyId        = "aws-kms:${aws_kms_key.asymmetric_credentials_encryption_key[0].arn}"
          algorithm    = "RSA_4096_OAEP_SHA256"
          publicKeyPem = data.aws_kms_public_key.asymmetric_credentials_encryption_public_key[0].public_key_pem
        } : {}
      }
      gretelWorkers = {
        images = {
          registry = var.gretel_image_registry_override_host
        }
        model = {
          maxConcurrent = var.gretel_max_workers
          serviceAccount = {
            name = var.gretel_model_worker_service_account
            annotations = {
              "eks.amazonaws.com/role-arn" = module.gretel_model_worker_irsa_role.iam_role_arn
            }
          }
          resources = {
            requests = {
              cpu               = var.gretel_model_worker_pod_cpu_count
              memory            = "${var.gretel_model_worker_pod_memory_gb}Gi"
              ephemeral-storage = "${var.gretel_model_worker_pod_ephemeral_storage_gb}Gi"
            }
            limits = {
              memory = "${var.gretel_model_worker_pod_memory_gb}Gi"
            }
          }
          cpu = {
            nodeSelector = var.gretel_cpu_model_worker_node_selector
            tolerations  = local.cpu_tolerations
          }
          gpu = {
            nodeSelector = var.gretel_gpu_model_worker_node_selector
            tolerations  = local.gpu_tolerations
          }
        }

        workflow = {
          serviceAccount = {
            name = var.gretel_workflow_worker_service_account
            annotations = {
              "eks.amazonaws.com/role-arn" = module.gretel_workflow_worker_irsa_role.iam_role_arn
            }
          }
        }
      }
    }),
    yamlencode(var.extra_helm_values),
  ]
}

data "aws_caller_identity" "current" {}
