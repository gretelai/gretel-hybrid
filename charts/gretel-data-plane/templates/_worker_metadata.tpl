{{- define "gretel-gcc.gretelWorkers.podLabels" }}
{{- toYaml .Values.gretelWorkers.podLabels }}
{{- end }}

{{- define "gretel-gcc.gretelWorkers.podAnnotations" }}
{{- $annotations := dict }}
{{- if .Values.gretelWorkers.preventAutoscalerEviction }}
{{- $_ := set $annotations "cluster-autoscaler.kubernetes.io/safe-to-evict" "false" }}
{{- end }}
{{- with .Values.gretelWorkers.podAnnotations }}
{{- $annotations = mergeOverwrite $annotations . }}
{{- end }}
{{- toYaml $annotations }}
{{- end }}
