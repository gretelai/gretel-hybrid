# Gretel Data Plane (GCC) Chart

Installing this chart will deploy a *Gretel Data Plane* (also referred to as
*Gretel Compute Cluster (GCC)*) in a self-managed cloud environment,
allowing the execution of [Gretel Hybrid](https://docs.gretel.ai/guides/environment-setup/running-gretel-hybrid) workloads (models, record handlers, and workflows) in a
customer-controlled environment.

## Deployment

The official way of deploying this chart is through the
[Terraform resources](https://github.com/gretelai/gretel-hybrid) for your respective cloud provider.
The following instructions are intended to provide you with a starting point if you require a more
custom setup and/or cannot use Terraform.

### Prerequisites

To deploy this chart, you will need:
- a recent version of [Helm](https://helm.sh) (we recommend version 3.11 or above)
- cloud infrastructure for deployment, including a Kubernetes cluster, an object storage bucket (S3, GCS etc.) for storing artifacts, and IAM role bindings for workload identities
- a Gretel API key for the *deployment user* (see next section)

### Deployment User

In order to authenticate with Gretel APIs, the services deployed via this chart need a Gretel API key,
which can be obtained through the [Gretel Console](https://console.gretel.ai/users/me/key). We recommend
that a dedicated user is created for this purpose, that is not used for any other everyday operations.

In order to have workflows executed in the deployed data plane, the deployment user has to be invited as an
**Administrator** to each project in which hybrid workflows are executed.

### Configuring the Deployment

The chart's [`values.yaml` file](./values.yaml) provides an authoritative reference of all supported
configuration options. However, most users will not have to change the majority of those. The following
table provides an overview of the configuration options that have to be specified in most deployments:

| Name                            | Description                                                                                                                            | Example Value          |
| ------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | ---------------------- |
| `gretelConfig.apiKey`           | The API key of the deployment user (**this or gretelConfig.apiKeySecretRef are required**)                                             | `grtu123456789...`     |
| `gretelConfig.artifactEndpoint` | The object store URI of the [Gretel Sink bucket](https://docs.gretel.ai/guides/environment-setup/running-gretel-hybrid) (**required**) | `s3://my-gretel-sink/` |
| `gretelConfig.artifactRegion`   | The region corresponding to the object store bucket above (**optional**, but encouraged for S3)                                        | `us-west-2`            |

> If you're using a secrets store CSI driver and would like to store your Gretel API key using an external service (like AWS Secrets Manager), [sync your external secret as a k8s secret](https://secrets-store-csi-driver.sigs.k8s.io/topics/sync-as-kubernetes-secret) and pass the name of the resulting k8s secret to `gretelConfig.apiKeySecretRef`. The opaque secret should contain the `GRETEL_API_KEY` key with your API key as the value. Leave `gretelConfig.apiKey` unset when using `gretelConfig.apiKeySecretRef`.

#### Worker IAM Role Bindings

Gretel Workers are compute units for executing various parts of the Gretel data plane (e.g., training
a synthetic data model). These containers need to interact with cloud provider resources, for example, storing artifacts in the sink bucket referenced via `gretelConfig.artifactEndpoint`.

Typically, these privileges are assigned at the level of Kubernetes Service accounts (e.g., AWS EKS: [IRSA - IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html), GCP GKE: [Workload Identities](https://cloud.google.com/kubernetes-engine/docs/concepts/workload-identity)). This typically requires two pieces of configuration:
- at the cloud provider level, the IAM role/identity needs to be allowlisted for use by a Kubernetes service account (namespace/name);
- at the Kubernetes level, the service account needs to be annotated with the IAM role/identity to assume.

To accomplish this, the chart offers the ability to customize both the _name_ of the service account
used for workers, as well as the _annotations_ applied to it. Note that there are two different types of
workers in the data plane: workflow workers, that execute steps in a workflow, and model workers,
that train or run machine learning models. These worker types use different service accounts, which can
be configured as follows:

| Name                                                | Description                                                                              | Example Value                                                                                |
| --------------------------------------------------- | ---------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| `gretelWorkers.workflow.serviceAccount.name`        | The name of the service account for executing workflow actions                           | `workflow-worker`                                                                            |
| `gretelWorkers.workflow.serviceAccount.annotations` | A dictionary of annotations to be applied to the corresponding `ServiceAccount` resource | `{"eks.amazonaws.com/role-arn": "arn:aws:iam::0123456789:role/gretel-workflow-worker-role"}` |
| `gretelWorkers.model.serviceAccount.name`           | The name of the service account for executing models                                     | `model-worker`                                                                               |
| `gretelWorkers.model.serviceAccount.annotations`    | A dictionary of annotations to be applied to the corresponding `ServiceAccount` resource | `{"eks.amazonaws.com/role-arn": "arn:aws:iam::0123456789:role/gretel-model-worker-role"}`    |

#### Worker Resource Consumption

In order to ensure optimal performance for running Gretel Hybrid workloads, workers require sufficient
resources (CPU and memory, sometimes GPU). In the default configuration, workflow workers request
4 gigabytes of memory, while model workers request 12 gigabytes. Depending on the node sizes on your
cluster, these limits may be inadequate (e.g., when nodes have less memory than that, workers might
remain stuck in an unschedulable state).

Worker resource utilization can be configured with the following options:

| Name                               | Description                                                                                                                                                                                        | Example Value                                                             |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| `gretelWorkers.workflow.resources` | [Kubernetes resource specification](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) to use for workflow workers.                                                   | `{"requests":{"memory": "2Gi"}, "limits": {"memory": "3Gi", "cpu": "2"}}` |
| `gretelWorkers.model.resources`    | [Kubernetes resource specification](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) to use for model workers. **Note:** GPU resources do not have to be specified. | `{"requests": {"memory": "10Gi"}, "limits": {"memory": "10Gi"}}`          |

#### Worker Placement

For a more efficient usage of compute resources, it is advisable to run different workloads on different
types of nodes. For example, only GPU model workers need to run on a node that has GPU resources.
Additionally, due to the resource intensity of these workloads, it can be a good idea to ensure that
these nodes are _dedicated_, meaning that regular workloads in the cluster are not allowed to run on them.

At the infrastructure level (beyond the scope of this README), the following two properties of nodes/node
pool need to be configured to accomplish this:
- _node labels_ allow selecting the nodes for placement,
- _node taints_ allow marking a node as ineligible for scheduling all but specifically designated workloads on.

In such a setup, worker placement can be configured (separately for all three worker types: workflow workers, CPU model workers, and GPU model workers) with the following options:

| Name                                  | Description                                                                                                                                                                                   | Example Value                                                                    |
| ------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| `gretelWorkers.workflow.nodeSelector` | [Kubernetes node selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector) to select the nodes (by their labels) that workflow workers should run on.  | `{"gretel.ai/worker-node-type": "workflow"}`                                     |
| `gretelWorkers.workflow.tolerations`  | List of [taint tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) that allow running the workflow worker on nodes with the respective taint.         | `[{"key": "gretel.ai/dedicated", "value": "workflow", "effect": "NoSchedule"}]`  |
| `gretelWorkers.workflow.nodeSelector` | [Kubernetes node selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector) to select the nodes (by their labels) that CPU model workers should run on. | `{"gretel.ai/worker-node-type": "cpu-model"}`                                    |
| `gretelWorkers.workflow.tolerations`  | List of [taint tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) that allow running the CPU model worker on nodes with the respective taint.        | `[{"key": "gretel.ai/dedicated", "value": "cpu-model", "effect": "NoSchedule"}]` |
| `gretelWorkers.workflow.nodeSelector` | [Kubernetes node selector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector) to select the nodes (by their labels) that GPU model workers should run on. | `{"gretel.ai/worker-node-type": "gpu-Model"}`                                    |
| `gretelWorkers.workflow.tolerations`  | List of [taint tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) that allow running the GPU model worker on nodes with the respective taint.        | `[{"key": "gretel.ai/dedicated", "value": "gpu-model", "effect": "NoSchedule"}]` |
