#!/usr/bin/env bash
SINK_BUCKET=gretel-hybrid-demo-sink-bucket
SINK_BUCKET=$(echo "var.sink_bucket_name" | terraform console -var-file terraform.tfvars | tr -d '"')
API_KEY=$(echo "var.gretel_api_key" | terraform console -var-file terraform.tfvars | tr -d '"')
if ! command -v gretel; then
    echo "Gretel Client could not be found, installing"
    pip3 install gretel-client
fi
gretel configure --endpoint https://api.gretel.cloud \
    --artifact-endpoint "gs://$SINK_BUCKET" \
    --default-runner hybrid \
    --api-key "$API_KEY" \
    --project ""
