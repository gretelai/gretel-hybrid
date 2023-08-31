/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

output "source_bucket_id" {
  description = "ID of the source GCS bucket"
  value       = module.gcs-bucket-source.id
}

output "sink_bucket_id" {
  description = "ID of the sink GCS bucket"
  value       = module.gcs-bucket-sink.id
}

output "vpc_self_link" {
  description = "Self link of VPC"
  value       = module.vpc.self_link
}

output "cluster_self_link" {
  description = "Self link of GKE autopilot cluster"
  value       = module.cluster.self_link
}
