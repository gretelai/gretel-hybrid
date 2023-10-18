{{/*
Expand the name of the chart.
*/}}
{{- define "gretel-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gretel-agent.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gretel-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gretel-agent.labels" -}}
helm.sh/chart: {{ include "gretel-agent.chart" . }}
{{ include "gretel-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gretel-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gretel-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "gretel-agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "gretel-agent.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Define the secretName
*/}}
{{- define "gretel-agent.secretName" -}}
{{- default "gretel-agent-secret" .Values.gretelConfig.secretName }}
{{- end }}

{{/*
Define the secretName
*/}}
{{- define "gretel-agent.workerSecretName" -}}
{{- default "gretel-worker-secret" .Values.gretelConfig.workerSecretName }}
{{- end }}

{{/*
Define the cert override configmap
*/}}
{{- define "gretel-agent.extraCaCertConfigmapName" -}}
{{ include "gretel-agent.fullname" . }}-extra-ca
{{- end }}