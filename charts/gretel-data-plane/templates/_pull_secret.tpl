{{- define "gretel-gcc.gretelWorkers.imagePullSecret.name" -}}
{{- if .Values.gretelAgent._enabled -}}
gretel-pull-secret
{{- end -}}
{{- end }}
{{- define "gretel-gcc.gretelWorkers.imagePullSecrets" -}}
{{- with .Values.imagePullSecrets -}}
{{ toYaml . }}
{{- end }}
{{ if .Values.gretelAgent._enabled -}}
- name: "gretel-pull-secret"
{{- end -}}
{{- end }}
