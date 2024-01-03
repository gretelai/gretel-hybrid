import aws_cdk.aws_iam as iam

from aws_cdk import Duration, Fn, Stack
from constructs import Construct
from gretel_iam.values import GretelIamValues


class GretelIamStack(Stack):
    def __init__(
        self, scope: Construct, construct_id: str, values: GretelIamValues, **kwargs
    ) -> None:
        super().__init__(scope, construct_id, **kwargs)

        # IRSA policies
        workflow_worker_policy = self.create_workflow_worker_iam_policy(
            sink_bucket=values.sink_bucket_name,
            kms_key_arn=values.kms_key_arn,
            policy_name=values.iam_policy_workflow_worker,
        )
        self.create_worker_iam_role(
            oidc_provider_arn=values.oidc_provider_arn,
            gretel_hybrid_namespace=values.hybrid_namespace,
            service_account=values.workflow_worker_service_account,
            role_name=values.iam_role_workflow_worker,
            worker_policy=workflow_worker_policy,
        )

        # IRSA roles
        model_worker_policy = self.create_model_worker_iam_policy(
            source_bucket=values.source_bucket_name,
            sink_bucket=values.sink_bucket_name,
            policy_name=values.iam_policy_model_worker,
        )
        self.create_worker_iam_role(
            oidc_provider_arn=values.oidc_provider_arn,
            gretel_hybrid_namespace=values.hybrid_namespace,
            service_account=values.model_worker_service_account,
            role_name=values.iam_role_model_worker,
            worker_policy=model_worker_policy,
        )

    def create_workflow_worker_iam_policy(
        self, sink_bucket: str, kms_key_arn: str, policy_name: str
    ) -> iam.ManagedPolicy:
        policy_doc = iam.PolicyDocument(
            statements=[
                iam.PolicyStatement(
                    actions=[
                        "s3:PutObjectTagging",
                        "s3:PutObject",
                        "s3:ListBucket",
                        "s3:GetObjectVersion",
                        "s3:GetObjectTagging",
                        "s3:GetObject",
                        "s3:GetBucketLocation",
                        "s3:DeleteObject",
                    ],
                    resources=[
                        f"arn:aws:s3:::{sink_bucket}/*",
                        f"arn:aws:s3:::{sink_bucket}",
                    ],
                ),
                iam.PolicyStatement(
                    actions=[
                        "kms:Decrypt",
                    ],
                    resources=[
                        f"{kms_key_arn}",
                    ],
                ),
            ]
        )
        return iam.ManagedPolicy(
            self,
            policy_name,
            managed_policy_name=policy_name,
            description="The EKS IRSA IAM policy used by Gretel Hybrid for workflow worker pods.",
            document=policy_doc,
        )

    def create_model_worker_iam_policy(
        self, source_bucket: str, sink_bucket: str, policy_name: str
    ) -> iam.PolicyDocument:
        policy_doc = iam.PolicyDocument(
            statements=[
                iam.PolicyStatement(
                    actions=["s3:ListBucket", "s3:GetObjectVersion", "s3:GetObject"],
                    resources=[
                        f"arn:aws:s3:::{source_bucket}/*",
                        f"arn:aws:s3:::{source_bucket}",
                    ],
                ),
                iam.PolicyStatement(
                    actions=[
                        "s3:PutObjectTagging",
                        "s3:PutObject",
                        "s3:ListBucket",
                        "s3:GetObjectVersion",
                        "s3:GetObjectTagging",
                        "s3:GetObject",
                        "s3:GetBucketLocation",
                        "s3:DeleteObject",
                    ],
                    resources=[
                        f"arn:aws:s3:::{sink_bucket}/*",
                        f"arn:aws:s3:::{sink_bucket}",
                    ],
                ),
            ]
        )
        return iam.ManagedPolicy(
            self,
            policy_name,
            managed_policy_name=policy_name,
            description="The EKS IRSA IAM policy used by Gretel Hybrid for model worker pods.",
            document=policy_doc,
        )

    def create_worker_iam_role(
        self,
        oidc_provider_arn: str,
        gretel_hybrid_namespace: str,
        service_account: str,
        role_name: str,
        worker_policy: iam.IManagedPolicy,
    ) -> None:
        oidc_trimmed = "/".join(oidc_provider_arn.split("/")[1:])
        federated_principal_workflow_workers = iam.FederatedPrincipal(
            federated=oidc_provider_arn,
            conditions={
                "StringEquals": {
                    f"{oidc_trimmed}:aud": "sts.amazonaws.com",
                    f"{oidc_trimmed}:sub": f"system:serviceaccount:{gretel_hybrid_namespace}:{service_account}",
                }
            },
            assume_role_action="sts:AssumeRoleWithWebIdentity",
        )
        iam.Role(
            self,
            role_name,
            role_name=role_name,
            assumed_by=federated_principal_workflow_workers,
            max_session_duration=Duration.minutes(60),
            managed_policies=[worker_policy],
        )
