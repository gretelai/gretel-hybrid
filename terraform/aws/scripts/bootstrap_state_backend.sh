#!/usr/bin/env bash

while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
  --aws-region)
    AWS_REGION="$2"
    shift
    shift
    ;;
  --bucket-name)
    BUCKET_NAME="$2"
    shift
    shift
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
done

if [ -z "$AWS_REGION" ] || [ -z "$BUCKET_NAME" ]; then
  echo "Usage: $0 --aws-region <AWS_REGION> --bucket-name <BUCKET_NAME>"
  exit 1
fi

# Create the S3 bucket
if aws s3api create-bucket --bucket $BUCKET_NAME --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION >/dev/null; then
  echo "S3 bucket '$BUCKET_NAME' created successfully."
else
  echo "Failed to create S3 bucket '$BUCKET_NAME'."
  exit 1
fi
# Enable versioning on the bucket
aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled

# Enable server-side encryption for the bucket using AWS managed keys
aws s3api put-bucket-encryption --bucket $BUCKET_NAME --server-side-encryption-configuration '{"Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]}'

# Configure bucket policy to restrict access to Terraform state files
cat <<EOF >bucket-policy.json
{
  "Version": "2012-10-17",
  "Id": "TerraformBucketPolicy",
  "Statement": [
    {
      "Sid": "DenyUnencryptedObjectUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::$BUCKET_NAME/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "AES256"
        }
      }
    }
  ]
}
EOF

aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://bucket-policy.json

rm -f bucket-policy.json

echo "Bucket '$BUCKET_NAME' is now ready to be used as a Terraform state backend."

echo ""
echo "Here is an example Terraform backend configuration:"
echo ""
echo "backend \"s3\" {"
echo "  bucket = \"$BUCKET_NAME\""
echo "  key    = \"state/aws-gretel-hybrid/terraform.tfstate\""
echo "  region = \"$AWS_REGION\""
echo "}"
