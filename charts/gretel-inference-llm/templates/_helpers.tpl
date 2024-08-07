{{- define "gretel-inference-llm.appName" -}}
{{- if .Values.appName -}}
{{- .Values.appName | trimSuffix "-" -}}
{{- else -}}
{{- .Chart.Name -}}
{{- end -}}
{{- end -}}

{{- /* Validate and lookup the `modelName` config */}}
{{- define "validateAndGetModelConfig" -}}
{{- if not (hasKey .Values.availableLLMConfigs .Values.gretelLLMConfig.modelName) -}}
  {{- fail (printf "Invalid modelName %q. Must be one of: %s" .Values.gretelLLMConfig.modelName (keys .Values.availableLLMConfigs | join ", ")) -}}
{{- end -}}
{{- index .Values.availableLLMConfigs .Values.gretelLLMConfig.modelName | toYaml -}}
{{- end -}}

{{- define "gretel-inference-llm.llmName" -}}
{{- $llmName := printf "llm-%s" .Values.gretelLLMConfig.modelName }}
{{- if gt (len $llmName) 63 -}}
{{- fail (printf "%s is too long, must be less than 63 characters" $llmName) -}}
{{- end -}}
{{- printf "%s" $llmName -}}
{{- end -}}

{{- define "gretel-inference-llm.instanceName" -}}
{{- $appName := include "gretel-inference-llm.appName" . }}
{{- printf "%s-%s" $appName .Values.gretelLLMConfig.modelName -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gretel-inference-llm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "gretel-inference-llm.labels" -}}
helm.sh/chart: {{ include "gretel-inference-llm.chart" . }}
{{ include "gretel-inference-llm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "gretel-inference-llm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "gretel-inference-llm.appName" . }}
app.kubernetes.io/instance: {{ include "gretel-inference-llm.instanceName" . }}
{{- end }}

{{- define "gretel-inference-llm.gretelConfig.apiKeySecretName" }}
{{- if .Values.gretelConfig.apiKey }}
{{- include "gretel-inference-llm.appName" . }}-gretel-api-key
{{- else }}
{{- .Values.gretelConfig.apiKeySecretRef }}
{{- end }}
{{- end -}}
