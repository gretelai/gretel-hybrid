# Overview

We are using the AWS CDK to generate CloudFormation templates. CDK installation is only required if you wish to regenerate the output CloudFormation templates for a specific CDK App.

[Installing the AWS CDK CLI and libraries.](https://docs.aws.amazon.com/cdk/v2/guide/getting_started.html)

# Quickstart for AWS CDK

```bash
# Node and CDK quick install.

# Install nvm (node version manager): https://github.com/nvm-sh/nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# Install Node 20 (LTS)
nvm install 20
nvm use 20
nvm alias default 20

# Install the CDK CLI
npm install -g aws-cdk
```

