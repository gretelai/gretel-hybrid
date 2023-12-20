# Overview

The intent of this module is to deploy only the necessary AWS resources for Gretel Hybrid. It is assumed the customer will be bringing their own EKS cluster.

# Deploying

1. Copy backend.tf.example and define your [Terraform backend](https://developer.hashicorp.com/terraform/language/settings/backends/configuration) within this file as desired.

```bash
cp backend.tf.example backend.tf
```

2. Copy provider.tf.example and defined your [AWS provider]() within this file as desired.

```bash
cp provider.tf.example provider.tf
```

3. Define your Terraform variables. You can do so use a [number of ways](https://developer.hashicorp.com/terraform/language/values/variables#assigning-values-to-root-module-variables). We provide an example in `terraform.tfvars.example` that you may utilize.

```bash
# If you wish to utilize a tfvars file to define your variables,
# run this command to create the properly named file and then
# open the terraform.tfvars file and review the values.
cp terraform.tfvars.example terraform.tfvars
```