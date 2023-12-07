#!/usr/bin/env bash
CLUSTER_NAME=$(echo "var.cluster_name" | terraform console -var-file terraform.tfvars | tr -d '"')
REGION=$(echo "var.region" | terraform console -var-file terraform.tfvars | tr -d '"')
GCP_PROJECT=$(echo "var.project_id" | terraform console -var-file terraform.tfvars | tr -d '"')
gcloud container clusters get-credentials "$CLUSTER_NAME" --region "$REGION" --project "$GCP_PROJECT"

# Update context
NAMESPACE=gretel-hybrid
kubectl config set-context "$(kubectl config current-context)" --namespace="$NAMESPACE"
