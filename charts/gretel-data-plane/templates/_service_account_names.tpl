{{/*
We define the names of the utilized service accounts here.
*/}}
{{- define "gretel-gcc.gretelController.serviceAccount.name" }}
{{- if .Values.gretelController.serviceAccount.name }}
{{- .Values.gretelController.serviceAccount.name }}
{{- else }}
{{- include "gretel-gcc.namePrefix" . }}controller
{{- end }}
{{- end }}

{{- define "gretel-gcc.gretelAgent.serviceAccount.name" }}
{{- if .Values.gretelAgent.serviceAccount.name }}
{{- .Values.gretelAgent.serviceAccount.name }}
{{- else }}
{{- include "gretel-gcc.namePrefix" . }}agent
{{- end }}
{{- end }}

{{- define "gretel-gcc.gretelWorkers.workflow.serviceAccount.name" }}
{{- if .Values.gretelWorkers.workflow.serviceAccount.name }}
{{- .Values.gretelWorkers.workflow.serviceAccount.name }}
{{- else }}
{{- include "gretel-gcc.namePrefix" . }}workflow-worker
{{- end }}
{{- end }}

{{- define "gretel-gcc.gretelWorkers.model.serviceAccount.name" }}
{{- if .Values.gretelWorkers.model.serviceAccount.name }}
{{- .Values.gretelWorkers.model.serviceAccount.name }}
{{- else }}
{{- include "gretel-gcc.namePrefix" . }}model-worker
{{- end }}
{{- end }}

{{- define "gretel-gcc.argoController.serviceAccount.name" }}
{{- if .Values.argoController.serviceAccount.name }}
{{- .Values.argoController.serviceAccount.name }}
{{- else }}
{{- include "gretel-gcc.namePrefix" . }}argo-controller
{{- end }}
{{- end }}
