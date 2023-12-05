{{/*
This function inserts any defined pod placement constraints (node selector,
affinity, tolerations). The argument given must be the config dict that contains
these fields.
*/}}
{{- define "gretel-gcc.podPlacement" }}
{{- /*
Add a newline separator only _between_ items, not before/after each.
This prevents rendering issues caused by stray blank lines. 
*/}}
{{- $sep := "" }}
{{- range $k, $v := pick . "nodeSelector" "affinity" "tolerations" }}
{{- with $v }}
{{- $sep }}{{ quote $k }}:
  {{- toYaml . | nindent 2 }}
  {{- $sep = "\n" }}
{{- end }}
{{- end }}
{{- end }}
