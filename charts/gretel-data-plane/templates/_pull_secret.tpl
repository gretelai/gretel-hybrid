{{- define "gretel-gcc.gretelWorkers.imagePullSecret.name" -}}
{{- if .Values.gretelAgent._enabled -}}
gretel-pull-secret
{{- end -}}
{{- end }}
