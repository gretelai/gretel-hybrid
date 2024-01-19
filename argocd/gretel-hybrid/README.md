# Deploy Gretel Hybrid with ArgoCD

This chart implements the [ArgoCD app of apps pattern](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/#app-of-apps-pattern) and will provide basic instructions for those who wish to deploy Gretel Hybrid using ArgoCD.

## Prerequisites

A functioning instance of ArgoCD must be deployed. See the [ArgoCD Getting Started Guide here](https://argo-cd.readthedocs.io/en/stable/getting_started/).

## Instructions

### Step 1 - Move this chart into git

You will need this chart to be hosted in a git repository that your team owns and that ArgoCD can access. Copy this `gretel-hybrid` directory to the git repo of your choice and commit it.

### Step 2 - Set gretel-data-plane values

We're deploying the Gretel Data Plane helm chart which is located in this git repository at `charts/gretel-data-plane`.

We need to customize the values contained in the `templates/gretel-data-plane-values.tpl` file for your specific deployment. Modify the `templates/gretel-data-plane-values.tpl` file within the chart that you copied to your git repo and set any necessary customized values. Consult the gretel-data-plane chart itself for help setting the right values.

### Step 3 - Deploy the API key secret

The Gretel Hybrid deployment will use a Gretel API key to interact with the Gretel Control Plane API. We need to make this API key accessible as a Kubernetes secret. We provide a basic example you can deploy with `kubectl` in the `basic-api-key-secret-example.yaml` file. You are able to configure this Kubernetes Secret [a number of ways](https://argo-cd.readthedocs.io/en/stable/operator-manual/secret-management/).

Regardless of how you choose to deploy the API key secret, make sure the `gretel-data-plane-values.tpl` file has the proper secret name set (matching the existing secret) for the `gretelConfig.apiKeySecretRef` value.

### Step 4 - Configure top level values

If you need to, set the proper values in the top level `values.yaml` file and commit your changes to your git repository.

### Step 5 - Create the ArgoCD application and sync it

**Be sure you have committed all changes to your values files to your git repository.**

Now that you have modified the values as needed, you can deploy this parent Chart with ArgoCD. You can do this via the ArgoCD UI [as shown here](https://argo-cd.readthedocs.io/en/stable/operator-manual/cluster-bootstrapping/#app-of-apps-pattern) or you can use the below example command, modifying the command flags as needed.

```sh
# Example repo url: https://github.com/argoproj/argocd-example-apps.git
argocd app create gretel \
    --dest-namespace argocd \
    --dest-server https://kubernetes.default.svc \
    --repo <your git repo url> \ 
    --path <path to this chart in the git repo>  
argocd app sync gretel  
```