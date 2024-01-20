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
{{/*
In the case where a list of pull secrets is specified
AND
an override registry is specified
we'll use the pull secrets, since this most likely
points to a pull through cache
otherwise we use the agent pull secret if hybrid is enabled
*/}}
{{- define "gretel-gcc.gretelWorkers.imagePullSecrets" -}}
{{- if and .Values.imagePullSecrets .Values.gretelWorkers.images.registry -}}
{{- range .Values.imagePullSecrets -}}
- "{{ . }}"
{{ end -}}
{{ else if .Values.gretelAgent._enabled -}}
- "gretel-pull-secret"
{{- end -}}
{{- end }}
