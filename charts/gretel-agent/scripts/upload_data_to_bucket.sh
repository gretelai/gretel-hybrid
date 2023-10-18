#!/usr/bin/bash
set -euo pipefail
CURRENT_DIR=$(dirname "$0")

# Get dependencies we need, like smart_open and requests
export PYTHONPATH=$(echo $(find /app/containers/agent -name site-packages) | sed -r 's/\s+/:/g')

# Download dataset
data_url=https://raw.githubusercontent.com/gretelai/gretel-blueprints/main/sample_data/sample-synthetic-healthcare.csv
python -c "import requests; print(requests.get('$data_url').text)" >sample-synthetic-healthcare.csv

# Upload dataset
test_file=sample-synthetic-healthcare.csv
test_file_bucket_path=${ARTIFACT_ENDPOINT}/test
export test_file_in_bucket=${test_file_bucket_path}/${test_file}
python ${CURRENT_DIR}/smart_upload_file.py \
    --bucket-path $test_file_bucket_path \
    --file-name $test_file
