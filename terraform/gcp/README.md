# Gretel.ai Hybrid Automation

This repo contains Terraform code for the GCP components required to run the customer-hosted portions of Gretel's platform.

## Usage

1. Clone this repo and navigate to the `terraform/examples/end-to-end-deployment` directory. Update these values in the `terraform.tfvars` file:

   - `project_id`
   - `billing_account`
   - `gcloud_platform`
   - `parent`
   - `region`
   - `remote_state_bucket_location`
   - `source_bucket_name`
   - `sink_bucket_name`
   - `terraform_service_account`

   The GCP project will be created with a name and ID equal to the `project_id` specified here, and so this value must be globally unique. The `gcloud_platform` variable is the platform you're using to run Terraform (valid values are 'darwin' or 'linux'). This is required by the `gcloud` module. The parent should be either a GCP folder or a GCP organization. The service account specified here will be used to create your GCP resources.

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

1. Export the following variables:

   ```bash
   export GCP_PROJECT=my-project # change based on your actual GCP project name
   export GOOG_SA_EMAIL="gretel-workload-sa@$GCP_PROJECT.iam.gserviceaccount.com"
   export KUBE_NAMESPACE="my-gretel-namespace"
   export KUBE_SA_NAME="gretel-agent"
   export SOURCE_BUCKET="my-gretel-source-bucket-1234" # change based on your actual source bucket name
   export SINK_BUCKET="my-gretel-sink-bucket-1234" # change based on your actual sink bucket name
   ```

1. Upload sample training data to your GCS source bucket:

   ```bash
   url=https://raw.githubusercontent.com/gretelai/gretel-blueprints/main/sample_data/sample-synthetic-healthcare.csv
   wget $url
   # or with curl
   # curl -o sample-synthetic-healthcare.csv $url
   gcloud storage cp sample-synthetic-healthcare.csv gs://$SOURCE_BUCKET
   ```

1. Create workload identity binding between the GCP service account for the workloads and the kubernetes service account that will be created in subsequent steps:

   ```bash
   gcloud iam service-accounts add-iam-policy-binding $GOOG_SA_EMAIL \
       --role "roles/iam.workloadIdentityUser" \
       --member "serviceAccount:$GCP_PROJECT.svc.id.goog[$KUBE_NAMESPACE/$KUBE_SA_NAME]"
   ```

1. SSH to the bastion host (get the ZONE from `terraform show`) using the following command:

   ```bash
   gcloud compute ssh --zone "$ZONE" "bastion" --tunnel-through-iap --project "$GCP_PROJECT"
   ```

1. Ensure you have a Gretel project (distinct from GCP project) and Gretel API key set up. See the [documentation](https://docs.gretel.ai/guides/environment-setup) for more details.

1. From the bastion, perform the following steps:

   1. Run

      ```bash
      gcloud container clusters get-credentials $CLUSTER_NAME --region $YOUR_REGION --project $GCP_PROJECT
      ```

      to connect to your GKE Autopilot cluster.

   1. Export the following variables:

      ```bash
      export GCP_PROJECT=my-project # change based on your actual GCP project name
      export GOOG_SA_EMAIL="gretel-workload-sa@$GCP_PROJECT.iam.gserviceaccount.com"
      export GRETEL_API_KEY="g..."
      export NODE_MEMORY_IN_GB=13 # Example, change as appropriate
      export SA_ANNOTATION="{\"iam.gke.io/gcp-service-account\":\"$GOOG_SA_EMAIL\"}"
      export GPU_NODE_SELECTOR="{\"cloud.google.com/gke-accelerator\":\"nvidia-tesla-t4\"}"
      export GRETEL_PROJECT=my-gretel-project # change based on your actual Gretel project name
      export MAX_WORKERS=2
      export KUBE_NAMESPACE="my-gretel-namespace"
      export KUBE_SA_NAME="gretel-agent"
      export SOURCE_BUCKET="my-gretel-source-bucket-1234" # change based on your actual source bucket name
      export SINK_BUCKET="my-gretel-sink-bucket-1234" # change based on your actual sink bucket name
      ```

   1. Install the gretel helm chart.

      ```bash
      helm repo add gretel-stable \
          https://gretel-blueprints-pub.s3.us-west-2.amazonaws.com/helm-charts/stable/
      helm repo update
      ```

      ```bash
      helm search repo gretel-agent
      ```

      ```bash
      helm install gretel-agent gretel-stable/gretel-agent \
        --create-namespace \
        --atomic --timeout 300s \
        --namespace $KUBE_NAMESPACE \
        --set gretelConfig.artifactEndpoint=gs://$SINK_BUCKET/ \
        --set gretelConfig.project=$GRETEL_PROJECT \
        --set gretelConfig.apiKey=$GRETEL_API_KEY \
        --set gretelConfig.maxWorkers=$MAX_WORKERS \
        --set gretelConfig.workerMemoryInGb=$NODE_MEMORY_IN_GB \
        --set gretelConfig.preventAutoscalerEviction=false \
        --set-json serviceAccount.annotations="$SA_ANNOTATION" \
        --set-json gretelConfig.gpuNodeSelector="$GPU_NODE_SELECTOR"
      ```

   1. The `gretel` CLI has been preinstalled on the bastion host, however you will still need to configure it. To do this, run

      ```bash
      gretel configure
      ```

      and enter the following info into the prompts:

      ```ini
      Endpoint [https://api.gretel.cloud]:
      Artifact Endpoint [cloud]: gs://$SOURCE_BUCKET
      Default Runner (cloud, local, hybrid) [cloud]: hybrid
      Gretel API Key [grtuf6c5****]: $GRETEL_API_KEY
      Default Project []: $GRETEL_PROJECT
      ```

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
