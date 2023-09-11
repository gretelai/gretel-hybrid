# Gretel GCP Infrastructure Module

This module creates the GCP infrastructure components required to run [Gretel Hybrid](https://docs.gretel.ai/guides/environment-setup/running-gretel-hybrid) in a GCP environment.

## Example

```hcl
module "gretel-infrastructure" {
  source             = "../gretel-gcp-infrastructure-module"
  project_id         = "my-gretel-project"
  region             = "us-west1"
  source_bucket_name = "gretelai-source-bucket-123456" # This name must be globally unique
  sink_bucket_name   = "gretelai-sink-bucket-123456" # This name must be globally unique
}
```

## Inputs

| Name                                                                                                                     | Description                                                                    | Type          | Default                | Required |
| ------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------ | ------------- | ---------------------- | :------: |
| <a name="input_bucket_location"></a> [bucket_location](#input_bucket_location)                                           | GCS bucket location for source and sink buckets                                | `string`      | `"US"`                 |    no    |
| <a name="input_cluster_name"></a> [cluster_name](#input_cluster_name)                                                    | Name to use for GKE cluster                                                    | `string`      | `"gretel-cluster"`     |    no    |
| <a name="input_firewall_policy_name"></a> [firewall_policy_name](#input_firewall_policy_name)                            | Name of firewall policy                                                        | `string`      | `"gretel-fw-policy"`   |    no    |
| <a name="input_master_authorized_ranges"></a> [master_authorized_ranges](#input_master_authorized_ranges)                | IP ranges with access to GKE control plane                                     | `map(string)` | `{}`                   |    no    |
| <a name="input_master_ipv4_cidr_block"></a> [master_ipv4_cidr_block](#input_master_ipv4_cidr_block)                      | Range to use for control plane                                                 | `string`      | `"192.168.0.0/28"`     |    no    |
| <a name="input_nat_name"></a> [nat_name](#input_nat_name)                                                                | Name of Cloud NAT                                                              | `string`      | `"gretel-nat"`         |    no    |
| <a name="input_project_id"></a> [project_id](#input_project_id)                                                          | ID of GCP project in which cluster resources will be deployed                  | `string`      | n/a                    |   yes    |
| <a name="input_region"></a> [region](#input_region)                                                                      | GCP region to use for cluster and associated networking resources              | `string`      | n/a                    |   yes    |
| <a name="input_release_channel"></a> [release_channel](#input_release_channel)                                           | Release channel to use for GKE cluster version upgrades                        | `string`      | `"REGULAR"`            |    no    |
| <a name="input_service_account_bastion_name"></a> [service_account_bastion_name](#input_service_account_bastion_name)    | Name of bastion service account                                                | `string`      | `"gretel-bastion-sa"`  |    no    |
| <a name="input_service_account_node_name"></a> [service_account_node_name](#input_service_account_node_name)             | Name of node service account                                                   | `string`      | `"gretel-node-sa"`     |    no    |
| <a name="input_service_account_workload_name"></a> [service_account_workload_name](#input_service_account_workload_name) | Name of workload service account                                               | `string`      | `"gretel-workload-sa"` |    no    |
| <a name="input_sink_bucket_name"></a> [sink_bucket_name](#input_sink_bucket_name)                                        | Unique name for sink GCS bucket                                                | `string`      | n/a                    |   yes    |
| <a name="input_source_bucket_name"></a> [source_bucket_name](#input_source_bucket_name)                                  | Unique name for source GCS bucket                                              | `string`      | n/a                    |   yes    |
| <a name="input_subnet_cidr_pods"></a> [subnet_cidr_pods](#input_subnet_cidr_pods)                                        | CIDR for the secondary range to be associated with GKE pods                    | `string`      | `"10.0.16.0/20"`       |    no    |
| <a name="input_subnet_cidr_primary"></a> [subnet_cidr_primary](#input_subnet_cidr_primary)                               | Primary CIDR range to use for subnet (GKE node IPs are pulled from this range) | `string`      | `"10.0.0.0/20"`        |    no    |
| <a name="input_subnet_cidr_services"></a> [subnet_cidr_services](#input_subnet_cidr_services)                            | CIDR for the secondary range to be associated with GKE services                | `string`      | `"10.0.32.0/20"`       |    no    |
| <a name="input_subnet_name"></a> [subnet_name](#input_subnet_name)                                                       | Name of the VPC subnet                                                         | `string`      | `"gretel-vpc"`         |    no    |
| <a name="input_vpc_name"></a> [vpc_name](#input_vpc_name)                                                                | Name of the VPC                                                                | `string`      | `"gretel-subnet"`      |    no    |

## Outputs

| Name                                                                                   | Description                        |
| -------------------------------------------------------------------------------------- | ---------------------------------- |
| <a name="output_cluster_self_link"></a> [cluster_self_link](#output_cluster_self_link) | Self link of GKE autopilot cluster |
| <a name="output_sink_bucket_id"></a> [sink_bucket_id](#output_sink_bucket_id)          | ID of the sink GCS bucket          |
| <a name="output_source_bucket_id"></a> [source_bucket_id](#output_source_bucket_id)    | ID of the source GCS bucket        |
| <a name="output_vpc_self_link"></a> [vpc_self_link](#output_vpc_self_link)             | Self link of VPC                   |
