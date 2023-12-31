
# Gretel Hybrid IAM Resources

This CDK App can be used to deploy resources with the CDK as normal, or it can be used to generate a vanilla CloudFormation template to deploy the required resources.

## Prerequisites

- [Node.js](https://nodejs.org/en). We recommend utilizing [nvm](https://github.com/nvm-sh/nvm) (node-version-manager) to manage you node installation.
- [AWS CDK](https://docs.aws.amazon.com/cdk/v2/guide/getting_started.html)
- [jq](https://jqlang.github.io/jq/)

## Customize Values

Since this CDK App serves is meant to provide a reusable deployment, the necessary value customizations are made in `values.yaml`. Please edit that file and configure your values appropriately.

## Generate Vanilla CloudFormation

```bash
make release
```

## Deploy with AWS CDK

Please utilize the official [CDK documentation](https://docs.aws.amazon.com/cdk/v2/guide/getting_started.html) to learn how to deploy a stack with the CDK CLI.

# Autogenerated CDK README

## Overview 

The `cdk.json` file tells the CDK Toolkit how to execute your app.

This project is set up like a standard Python project.  The initialization
process also creates a virtualenv within this project, stored under the `.venv`
directory.  To create the virtualenv it assumes that there is a `python3`
(or `python` for Windows) executable in your path with access to the `venv`
package. If for any reason the automatic creation of the virtualenv fails,
you can create the virtualenv manually.

To manually create a virtualenv on MacOS and Linux:

```sh
$ python3 -m venv .venv
```

After the init process completes and the virtualenv is created, you can use the following
step to activate your virtualenv.

```sh
$ source .venv/bin/activate
```

If you are a Windows platform, you would activate the virtualenv like this:

```
% .venv\Scripts\activate.bat
```

Once the virtualenv is activated, you can install the required dependencies.

```sh
$ pip install -r requirements.txt
```

At this point you can now synthesize the CloudFormation template for this code.

```sh
$ cdk synth
```

To add additional dependencies, for example other CDK libraries, just add
them to your `setup.py` file and rerun the `pip install -r requirements.txt`
command.

## Useful commands

 * `cdk ls`          list all stacks in the app
 * `cdk synth`       emits the synthesized CloudFormation template
 * `cdk deploy`      deploy this stack to your default AWS account/region
 * `cdk diff`        compare deployed stack with current state
 * `cdk docs`        open CDK documentation

Enjoy!
