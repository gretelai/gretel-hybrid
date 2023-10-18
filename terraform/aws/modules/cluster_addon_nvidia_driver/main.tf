locals {
  nvidia_device_plugin_chart_version = var.nvidia_device_plugin_chart_version
  nvidia_device_plugin_namespace     = var.nvidia_device_plugin_namespace
  gpu_worker_node_group_labels       = var.gpu_worker_node_group_labels
  gpu_worker_node_group_taints       = var.gpu_worker_node_group_taints
}

resource "helm_release" "nvidia_gpu_device_daemonset" {
  name             = "nvidia-device-plugin"
  repository       = "https://nvidia.github.io/k8s-device-plugin"
  chart            = "nvidia-device-plugin"
  version          = local.nvidia_device_plugin_chart_version
  namespace        = local.nvidia_device_plugin_namespace
  create_namespace = true

  values = [yamlencode({
    affinity = {
      nodeAffinity = {
        requiredDuringSchedulingIgnoredDuringExecution = {
          nodeSelectorTerms = [
            {
              matchExpressions = [for label in local.gpu_worker_node_group_labels :
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
    tolerations = [for taint in local.gpu_worker_node_group_taints :
      {
        key      = taint.key
        operator = "Equal"
        value    = taint.value
        effect   = taint.effect
      }
    ]

  })]
}
