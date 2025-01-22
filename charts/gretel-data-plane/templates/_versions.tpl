{{- define "gretel-gcc.appVersion" -}}
{{- if hasPrefix "-" .Values.appVersion -}}
{{- printf "%s%s" .Chart.AppVersion .Values.appVersion -}}
{{- else -}}
{{- .Values.appVersion | default .Chart.AppVersion -}}
{{- end -}}
{{- end -}}

{{- define "gretel-gcc.gretelController.image.tag" -}}
{{- .Values.gretelController.image.tag | default (include "gretel-gcc.appVersion" .) -}}
{{- end -}}

{{- define "gretel-gcc.gretelAgent.image.tag" -}}
{{- .Values.gretelAgent.image.tag | default (include "gretel-gcc.appVersion" .) -}}
{{- end -}}


{{- define "gretel-gcc.gretelController.supervisor.image.tag" -}}
{{- .Values.gretelController.supervisor.image.tag | default (include "gretel-gcc.appVersion" .) -}}
{{- end -}}

{{- define "gretel-gcc.gretelController.supervisor.image" -}}
{{- if (kindIs "string" .Values.gretelController.supervisor.image) -}}
{{- .Values.gretelController.supervisor.image | default (include "gretel-gcc.appVersion" . | printf "gcc/supervisor-hybrid:%s") -}}
{{- else -}}
{{ printf "%s:%s" .Values.gretelController.supervisor.image.repository (include "gretel-gcc.gretelController.supervisor.image.tag" .) -}}
{{- end -}}
{{- end -}}
