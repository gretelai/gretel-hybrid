# Gretel.ai Hybrid Automation

This repo contains Terraform code for the GCP components required to run the customer-hosted portions of Gretel's platform.

## Usage

1. Clone this repo and navigate to the `terraform/examples/new-project` directory. (If you are working within an existing GCP project, then navigate to `terraform/examples/preexisting-project`.)

   Update these values in the `terraform.tfvars` file for `new-project`:

   - `project_id`
   - `billing_account`
   - `gcloud_platform`
   - `parent`
   - `region`
   - `remote_state_bucket_location`
   - `terraform_service_account`
   - `cluster_name`

   The GCP project will be created with a name and ID equal to the `project_id` specified here, and so this value must be globally unique.

   If you want to use a preexisting-project instead, update these values in the `terraform.tfvars` file for `preexisting-project`:

   - `project_id`
   - `gcloud_platform`
   - `region`
   - `remote_state_bucket_location`
   - `terraform_service_account`

   The `gcloud_platform` variable is the platform you're using to run Terraform (valid values are 'darwin' or 'linux'). This is required by the `gcloud` module. The parent should be either a GCP folder or a GCP organization. The service account specified here will be used to create your GCP resources.

   Once these updates are made, run the following commands:

   ```bash
   terraform init
   terraform apply
   ```

   Verify that the resources being created are what you expect and then type `yes` to complete the apply.

1. The state for the resources created so far is stored locally. In order to migrate it to the just-created GCS bucket for terraform state, uncomment the following block:

   ```hcl
   #terraform {
   #  backend "gcs" {
   #    bucket = "gretelai-terraform-remote-state"
   #    prefix = "state"
   #  }
   #}
   ```

   Then run

   ```bash
   terraform init -migrate-state
   ```

   and type `yes` in response to the prompt.

1. Now we need to do the chart install and bucket setup. Move over to the `terraform/examples/helm-deployment` folder. Update these values in the `terraform.tfvars` file:

   - `project_id`
   - `gcloud_platform`
   - `region`
   - `source_bucket_name`
   - `sink_bucket_name`
   - `terraform_service_account`
   - `cluster_name`
   - `gretel_api_key`

   You can get your Gretel API key following these [instructions](https://docs.gretel.ai/guides/environment-setup)

1. Run the terraform as above, migrating the state as necessary to the same state bucket created in the first part, i.e.

   ```bash
   terraform init
   terraform apply
   ```

   And to migrate the state, uncomment the following block:

   ```hcl
   #terraform {
   #  backend "gcs" {
   #    bucket = "gretelai-terraform-remote-state"
   #    prefix = "state"
   #  }
   #}
   ```

   Then run

   ```bash
   terraform init -migrate-state
   ```

   and type `yes` in response to the prompt.

1. Test the deployment.

   CPU-based example:

   ```bash
   gretel models create --config synthetics/amplify \
      --in-data gs://$SOURCE_BUCKET/sample-synthetic-healthcare.csv \
      --runner manual \
      --project $GRETEL_PROJECT
   ```

   GPU-based example:

   ```bash
   gretel models create --config synthetics/tabular-actgan \
         --in-data gs://$SOURCE_BUCKET/sample-synthetic-healthcare.csv \
         --runner manual \
         --project $GRETEL_PROJECT
   ```
