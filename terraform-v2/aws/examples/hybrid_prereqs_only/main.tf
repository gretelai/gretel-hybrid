terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_eks_cluster" "existing_cluster" {
  name = var.existing_eks_cluster_name
}

data "aws_iam_openid_connect_provider" "existing_cluster" {
  arn = var.existing_eks_cluster_oidc_provider_arn
}

locals {
  region = var.region
  # aws_tags may be passed to all modules and all created resources will have these tags.
  # This provides for easy identification of all resources created by these modules.
  aws_tags = {
    gretel-hybrid-cluster = var.deployment_name
  }
}

# Creates the Gretel IAM Roles (configures IRSA), KMS Key, source s3 bucket, sink s3 bucket,
# configures any necessary IAM policies. Skips creating the namespace or deploying the
# Gretel Hybrid helm chart thanks to the "deploy_kubernetes_resources" var being set to false.
module "gretel_hybrid" {
  source = "../../modules/gretel_hybrid"

  # Don't deploy the namespace or helm chart
  skip_kubernetes_resources = true

  # Pulled from existing resources
  cluster_name              = var.existing_eks_cluster_name
  gretel_hybrid_namespace   = var.existing_gretel_hybrid_namespace
  cluster_oidc_provider_arn = data.aws_iam_openid_connect_provider.existing_cluster.arn

  # Buckets are created with these names
  gretel_source_bucket_name = var.gretel_source_bucket_name
  gretel_sink_bucket_name   = var.gretel_sink_bucket_name


  # Grant permissions to users to encrypt credentials for Gretel Connectors using the AWS CLI
  gretel_credentials_encryption_key_user_arns = var.gretel_credentials_encryption_user_arns

  # These vars control the names of resources created by the module.
  gretel_credentials_encryption_key_alias = "${var.deployment_name}-credentials-encryption-key"
  gretel_workflow_worker_iam_role_name    = "${var.deployment_name}-workflow-worker-role"
  gretel_workflow_worker_iam_policy_name  = "${var.deployment_name}-workflow-worker-policy"
  gretel_model_worker_iam_role_name       = "${var.deployment_name}-model-worker-role"
  gretel_model_worker_iam_policy_name     = "${var.deployment_name}-model-worker-policy"

  # Do not need to set or change this as only the helm chart requires this var
  gretel_api_key = "skip"

  # Misc
  aws_tags = local.aws_tags
}
