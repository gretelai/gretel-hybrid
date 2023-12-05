{{/*
Common labels
*/}}
{{- define "gretel-gcc.labels" -}}
helm.sh/chart: "{{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}"
{{ include "gretel-gcc.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gretel-gcc.selectorLabels" -}}
app.kubernetes.io/name: "{{ include "gretel-gcc.appName" . }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
{{- end }}
