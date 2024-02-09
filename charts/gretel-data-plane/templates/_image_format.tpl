{{- define "gretel-gcc.gretelWorkers.usesDockerhubImageFormat" -}}
{{- if not (kindIs "invalid" .Values.gretelWorkers.images.usesDockerhubImageFormat) -}}
{{- .Values.gretelWorkers.images.usesDockerhubImageFormat -}}
{{- else if  eq .Values.gretelWorkers.images.registry "registry.gretel.ai" -}}
false
{{- else if .Values.gretelWorkers.images.registry -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}
