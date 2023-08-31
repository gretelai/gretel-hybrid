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

project_id                   = "my-project"
billing_account              = "123456-123456-123456"
gcloud_platform              = "darwin"
parent                       = "folders/123456789123"
region                       = "us-west3"
remote_state_bucket_location = "US"
source_bucket_name           = "gretelai-source-bucket-123456"
sink_bucket_name             = "gretelai-sink-bucket-123456"
terraform_service_account    = "iac-creator@my-project.iam.gserviceaccount.com"
