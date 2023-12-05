{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gretel-gcc.appName" -}}
{{- if .Values.appName -}}
{{- .Values.appName | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Chart.Name -}}
{{- end -}}
{{- end -}}
