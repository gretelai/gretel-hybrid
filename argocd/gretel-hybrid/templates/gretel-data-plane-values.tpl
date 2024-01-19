{{- define "gretel-data-plane.values" -}}
gretelConfig:
  apiKeySecretRef: gretel-api-key
  ## URI of the object store ("sink bucket") used for storing Gretel artifacts (required)
  ## eg. s3://my-sink-bucket, gs://my-sink-bucket, or azure://my-sink-storage-container
  artifactEndpoint: "gs://example-gretel-hybrid-sink"
gretelWorkers:
  workflow:
    serviceAccount:
      annotations:
        iam.gke.io/gcp-service-account: workflow-worker@example-project.iam.gserviceaccount.com
  model:
    serviceAccount:
      annotations:
        iam.gke.io/gcp-service-account: model-worker@example-project.iam.gserviceaccount.com
    resources:
      requests:
        cpu: "1"
        memory: 12Gi
      limits:
        memory: 12Gi
    cpu:
      nodeSelector:
        gretel-worker: cpu-model
      tolerations:
        - key: gretel-worker
          operator: Equal
          value: cpu-model
          effect: NoSchedule
    gpu:
      nodeSelector:
        gretel-worker: gpu-model
      affinity: {}
      tolerations:
        - key: gretel-worker
          operator: Equal
          value: gpu-model
          effect: NoSchedule
        - key: nvidia.com/gpu
          operator: Equal
          value: present
          effect: NoSchedule
argoExtraConfig:
  ## Controls whether CRDs are deployed. Set to false for clusters already running ArgoCD.
  deployCRDs: false
{{- end -}}