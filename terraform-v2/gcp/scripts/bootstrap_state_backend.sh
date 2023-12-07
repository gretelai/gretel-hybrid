#!/usr/bin/env bash

set -euo pipefail

# Function to display help message
function show_help {
  echo "Usage: $0 -b|--bucket-name BUCKET_NAME -l|--location LOCATION"
  exit 1
}

# Initialize variables
bucket_name=""
location=""

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
  case $1 in
  -b | --bucket-name)
    bucket_name="$2"
    shift
    ;;
  -l | --location)
    location="$2"
    shift
    ;;
  -h | --help | help)
    show_help
    ;;
  *)
    echo "Error: Unknown option '$1'."
    show_help
    ;;
  esac
  shift
done

# Check if required options are provided
if [[ -z "$bucket_name" || -z "$location" ]]; then
  echo "Error: Both bucket name and location are required."
  show_help
fi

# Check if gcloud is installed
if ! command -v gcloud &>/dev/null; then
  echo "Error: gcloud command not found. Please install Google Cloud SDK."
  exit 1
fi

# Check if the user is authenticated
if [[ -z "$(gcloud auth list --filter=status:ACTIVE --format='value(account)')" ]]; then
  echo "Error: You are not authenticated with Google Cloud. Please run 'gcloud auth login'."
  exit 1
fi

# Check if project is set
if [[ -z "$(gcloud config get-value project)" ]]; then
  echo "Error: Google Cloud project is not set. Please run 'gcloud config set project PROJECT_ID'."
  exit 1
fi

# Check if the bucket already exists
if gsutil ls -b "gs://$bucket_name" &>/dev/null; then
  echo "Error: Bucket '$bucket_name' already exists."
  exit 1
fi

# Create the bucket
gcloud storage buckets create "gs://$bucket_name" --location "$location"

echo "Bucket '$bucket_name' created successfully in location '$location'."

# Echo example Terraform backend configuration
echo ""
echo "Example Terraform Backend Configuration for GCS:"
echo "----------------------------------------------"
echo 'terraform {'
echo '  backend "gcs" {'
echo "    bucket  = \"$bucket_name\""
echo '    prefix  = "terraform/state"'
echo '  }'
echo '}'
