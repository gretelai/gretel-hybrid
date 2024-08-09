terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.13.2"
    }
  }
}

resource "helm_release" "nvidia_gpu_device_daemonset" {
  name             = "nvidia-device-plugin"
  repository       = "https://nvidia.github.io/k8s-device-plugin"
  chart            = "nvidia-device-plugin"
  version          = var.nvidia_device_plugin_chart_version
  namespace        = var.nvidia_device_plugin_namespace
  create_namespace = true

  values = [yamlencode({
    affinity = {
      nodeAffinity = {
        requiredDuringSchedulingIgnoredDuringExecution = {
          nodeSelectorTerms = [
            {
              matchExpressions = [for label in var.gpu_model_worker_node_group_labels :
                {
                  key      = label.key
                  operator = "In"
                  values = [
                    label.value
                  ]
                }
              ]
            }
          ]
        }
      }
    }
    tolerations = [for taint in var.gpu_model_worker_node_group_taints :
      {
        key      = taint.key
        operator = "Equal"
        value    = taint.value
        effect   = taint.effect
      }
    ]

  })]
}
