#!/usr/bin/bash
set -euo pipefail
gretel() {
    /gretel-entrypoint-wrapper.sh "$@"
}
CURRENT_DIR=$(dirname "$0")

. ${CURRENT_DIR}/upload_data_to_bucket.sh

# Run amplify job
if [[ -z "${GRETEL_PROJECT:-}" ]]; then
    gretel projects create --set-default
fi
gretel models create --config synthetics/amplify \
    --in-data $test_file_in_bucket \
    --runner manual
