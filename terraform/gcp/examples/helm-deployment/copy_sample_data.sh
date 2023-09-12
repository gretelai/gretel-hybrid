#!/usr/bin/env bash
url=https://raw.githubusercontent.com/gretelai/gretel-blueprints/main/sample_data/sample-synthetic-healthcare.csv
# or with curl
curl -o sample-synthetic-healthcare.csv $url
SOURCE_BUCKET=$(echo "var.source_bucket_name" | terraform console -var-file terraform.tfvars | tr -d '"')
gcloud storage cp sample-synthetic-healthcare.csv "gs://$SOURCE_BUCKET"
