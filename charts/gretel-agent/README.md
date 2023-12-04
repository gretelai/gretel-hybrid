# Gretel Agents Chart

## Running helm tests

Once installed, run `helm test gretel-agent` to test running an amplify model against the project/ bucket you've chosen.

## Parameters

### Common parameters

| Name                         | Description                                                                                         | Value                                      |
| ---------------------------- | --------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| `image.repository`           | Public Gretel ECR repository and registry                                                           | `public.ecr.aws/gretelai/gretel-k8s-agent` |
| `image.pullPolicy`           | Policy on how often to pull the image                                                               | `IfNotPresent`                             |
| `image.tag`                  | Agent image tag                                                                                     | `""`                                       |
| `nameOverride`               | String to partially override the name of the chart and resources                                    | `""`                                       |
| `fullnameOverride`           | String to fully override gretel-agent.fullname                                                      | `""`                                       |
| `serviceAccount.create`      | Enable creation of this service account. Note: pods will fail to start if no service account exists | `true`                                     |
| `serviceAccount.name`        | Name of the service account                                                                         | `gretel-agent`                             |
| `serviceAccount.annotations` | Annotations needed by the service account, maybe for some type of IAM access                        | `{}`                                       |
| `podAnnotations`             | Annotations for the agent pod                                                                       | `{}`                                       |
| `podSecurityContext`         | Security context for the agent pod                                                                  | `{}`                                       |
| `securityContext`            | Security context for the agent containres                                                           | `{}`                                       |
| `resources.limits.memory`    | The resources memory limits for the agent container                                                 | `528Mi`                                    |
| `resources.requests.cpu`     | The requested cpu resources for the agent container                                                 | `0.5`                                      |
| `resources.requests.memory`  | The requested memory resources for the agent container                                              | `528Mi`                                    |
| `nodeSelector`               | The node selector for the agent pod                                                                 | `{}`                                       |
| `tolerations`                | The list of tolerations for the agent pod                                                           | `[]`                                       |
| `affinity`                   | The affinity for the agent pod                                                                      | `{}`                                       |

### Gretel Parameters

| Name                                     | Description                                                                  | Value                      |
| ---------------------------------------- | ---------------------------------------------------------------------------- | -------------------------- |
| `gretelConfig.artifactEndpoint`          | S3/GCS/Azure storage path, used to upload model related artifacts            | `""`                       |
| `gretelConfig.apiEndpoint`               | API endpoint to receive Gretel Jobs                                          | `https://api.gretel.cloud` |
| `gretelConfig.apiKey`                    | Key used to authenticate to the Gretel API                                   | `""`                       |
| `gretelConfig.apiKeySecretRef`           | Existing k8s secret containing GRETEL_API_KEY. Use instead of apiKey.        | `""`                       |
| `gretelConfig.project`                   | Project to receive jobs from                                                 | `""`                       |
| `gretelConfig.workerEnv`                 | Environment variables to be passed to the worker pods                        | `nil`                      |
| `gretelConfig.workerMemoryInGb`          | Memory size in GB for the worker pods                                        | `14`                       |
| `gretelConfig.maxWorkers`                | Number of workers to spawn concurrently from the agent                       | `0`                        |
| `gretelConfig.gpuNodeSelector`           | Node selector for selecting GPUs based jobs                                  | `{}`                       |
| `gretelConfig.cpuNodeSelector`           | Node selector for selecting CPU based jobs                                   | `{}`                       |
| `gretelConfig.gpuTolerations`            | Tolerations for GPU based jobs                                               | `[]`                       |
| `gretelConfig.cpuTolerations`            | Tolerations for CPU based jobs                                               | `[]`                       |
| `gretelConfig.cpuCount`                  | Integer value specifying number of CPUs to use for workers                   | `""`                       |
| `gretelConfig.extraCaCert`               | PEM certificate file contents to be used by the agent/workers                | `""`                       |
| `gretelConfig.imageRegistryOverrideHost` | URL to override the image registry used to fetch worker images               | `""`                       |
| `gretelConfig.preventAutoscalerEviction` | Adds an annotation to Gretel jobs to prevent being evicted by the autoscaler | `true`                     |

> If you're using a secrets store CSI driver and would like to store your Gretel API key using an external service (like AWS Secrets Manager), [sync your external secret as a k8s secret](https://secrets-store-csi-driver.sigs.k8s.io/topics/sync-as-kubernetes-secret) and pass the name of the resulting k8s secret to `gretelConfig.apiKeySecretRef`. The opaque secret should contain the GRETEL_API_KEY key with your API key as the value. Leave `gretelConfig.apiKey` unset when using `gretelConfig.apiKeySecretRef`.