#!/usr/bin/env bash
SOURCE_BUCKET=$(echo "var.source_bucket_name" | terraform console -var-file terraform.tfvars | tr -d '"')
GRETEL_PROJECT="CPU-test-$RANDOM"
gretel projects create --name "$GRETEL_PROJECT" --display-name "CPU Test"
gretel models create --config synthetics/tabular-actgan \
    --in-data "gs://$SOURCE_BUCKET/sample-synthetic-healthcare.csv" \
    --project $GRETEL_PROJECT
