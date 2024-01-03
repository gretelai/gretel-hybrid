#!/usr/bin/env python3
import aws_cdk as cdk

from gretel_iam.gretel_iam_stack import GretelIamStack
from gretel_iam.values import load_values

values = load_values("values.yaml")
app = cdk.App()
GretelIamStack(
    scope=app,
    construct_id="GretelIamStack",
    values=values,
)

app.synth()
