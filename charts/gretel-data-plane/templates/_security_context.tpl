{{- define "gretel-gcc.gretelController.securityContext" -}}
{{- if .Values.gretelController.securityContext -}}
{{- with .Values.gretelController.securityContext -}}
{{- toYaml . }}
{{- end -}}
{{- else if .Values.securityContext -}}
{{- with .Values.securityContext -}}
{{- toYaml . }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "gretel-gcc.argoController.securityContext" -}}
{{- if .Values.argoController.securityContext -}}
{{- with .Values.argoController.securityContext -}}
{{- toYaml . }}
{{- end -}}
{{- else if .Values.securityContext -}}
{{- with .Values.securityContext -}}
{{- toYaml . }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "gretel-gcc.gretelWorkers.workflow.securityContext" -}}
{{- if .Values.gretelWorkers.workflow.securityContext -}}
{{- with .Values.gretelWorkers.workflow.securityContext -}}
{{- toYaml . }}
{{- end -}}
{{- else if .Values.securityContext -}}
{{- with .Values.securityContext -}}
{{- toYaml . }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "gretel-gcc.gretelAgent.securityContext" -}}
{{- if .Values.gretelAgent.securityContext -}}
{{- with .Values.gretelAgent.securityContext -}}
{{- toYaml . }}
{{- end -}}
{{- else if .Values.securityContext -}}
{{- with .Values.securityContext -}}
{{- toYaml . }}
{{- end -}}
{{- end -}}
{{- end -}}
