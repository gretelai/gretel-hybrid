{{/*
  Constructs the Argo Artifact Repository configuration from either the config
  provided as-is (via .Values.argoConfig.artifactRepository), or by parsing the URI
  specified in .Values.gretelConfig.artifactEndpoint (and maybe the region).
*/}}
{{- define "gretel-gcc.argoArtifactRepository" }}
{{- with .Values.argoConfig.artifactRepository }}
{{ . | toYaml }}
{{- else }}
{{- $parsedEndpoint := required "gretelConfig.artifactEndpoint must be set" .Values.gretelConfig.artifactEndpoint | splitn "://" 2 }}
{{- $scheme := $parsedEndpoint._0 }}
{{- $bucketAndPrefix := required "gretelConfig.artifactEndpoint must be a URI" $parsedEndpoint._1 | trimSuffix "/" | splitn "/" 2 }}
{{- $bucket := $bucketAndPrefix._0 }}
{{- $prefix := $bucketAndPrefix._1 | default "" }}
{{- if $prefix }}
{{- fail "gretelConfig.artifactEndpoint must be the root of a bucket, without any key prefix" }}
{{- end }}
{{- if eq $scheme "s3" -}}
s3:
  bucket: {{ $bucket | quote }}
  endpoint: s3.amazonaws.com
  {{- with .Values.gretelConfig.artifactRegion }}
  region: {{ . | quote }}
  {{- end }}
  useSDKCreds: true
{{- else if eq $scheme "gs" -}}
gcs:
  bucket: {{ $bucket | quote }}
{{- else if eq $scheme "azure" -}}
{{- $storageAccountName := get .Values.gretelWorkers.env "AZURE_STORAGE_ACCOUNT_NAME" | required "An Azure storage account name must be set via the AZURE_STORAGE_ACCOUNT_NAME worker environment variable (or configure argoConfig.artifactRepository directly with the correct settings)" }}
{{- $storageDomain := get .Values.gretelWorkers.env "AZURE_STORAGE_DOMAIN" | default "windows.net" }}
azure:
  endpoint: "https://{{ $storageAccountName }}.blob.core.{{ $storageDomain }}/"
  container: {{ $bucket | quote }}
  useSDKCreds: true
{{- else }}
{{ printf "Unsupported artifact endpoint scheme %s" $scheme | fail }}
{{- end }}
{{- end }}
{{- end }}
