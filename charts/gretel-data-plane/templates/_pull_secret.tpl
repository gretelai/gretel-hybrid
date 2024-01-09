{{- define "gretel-gcc.gretelWorkers.imagePullSecret.name" -}}
{{- if .Values.gretelAgent._enabled -}}
gretel-pull-secret
{{- end -}}
{{- end }}
{{- define "gretel-gcc.imagePullSecrets" -}}
{{ with .Values.imagePullSecrets }}
imagePullSecrets:
{{- range . }}
  - name: {{ . -}}
{{- end }}
{{- end }}
{{- end }}
{{- define "gretel-gcc.gretelWorkers.imagePullSecrets" -}}
{{- range .Values.imagePullSecrets -}}
- "{{ . }}"
{{ end -}}
{{ if .Values.gretelAgent._enabled -}}
- "gretel-pull-secret"
{{- end -}}
{{- end }}
