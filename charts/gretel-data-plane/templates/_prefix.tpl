{{- define "gretel-gcc.namePrefix" -}}
{{- if .Values.namePrefix -}}
{{ .Values.namePrefix | trimSuffix "-" }}-
{{- end -}}
{{- end -}}
