from dataclasses import dataclass

import yaml


@dataclass
class GretelIamValues:
    # Existing AWS resources
    oidc_provider_arn: str
    kms_key_arn: str
    source_bucket_name: str
    sink_bucket_name: str

    # Existing k8s resources
    hybrid_namespace: str
    workflow_worker_service_account: str
    model_worker_service_account: str

    # Control output resources
    iam_policy_workflow_worker: str
    iam_policy_model_worker: str
    iam_role_workflow_worker: str
    iam_role_model_worker: str


def load_values(filename: str) -> GretelIamValues:
    with open(filename, "r") as values_file:
        values = yaml.safe_load(values_file)
        return GretelIamValues(**values)
