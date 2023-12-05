{{- define "gretel-gcc.commonData.mountPath" -}}
/gretel/common-data
{{- end -}}

{{- define "gretel-gcc.commonData.envFrom" -}}
secretRef:
  name: {{ include "gretel-gcc.namePrefix" . }}common-env-secret
{{- end -}}

{{- define "gretel-gcc.commonData.volume" -}}
name: common-data
secret:
  secretName: {{ include "gretel-gcc.namePrefix" . }}common-data-secret
{{- end -}}

{{- define "gretel-gcc.commonData.volumeMount" -}}
name: common-data
mountPath: {{ include "gretel-gcc.commonData.mountPath" . }}
{{- end -}}
