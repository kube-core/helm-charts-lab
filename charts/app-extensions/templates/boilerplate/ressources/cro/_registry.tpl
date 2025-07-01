{{- define "app-extensions.cro-registry" -}}
{{- $name := (coalesce .value.name .key) }}
{{- $resourceName := (coalesce .value.resourceName .value.name .key) }}
apiVersion: neo9.io/v1
kind: ContainerRegistry
metadata:
  name: {{ $resourceName }}
spec:
  imageRegistry: {{ .value.imageRegistry }}
  hostname: {{ .value.hostname }}
  project: {{ coalesce .value.project .common.cloud.project }}
  secretName: {{ coalesce .value.secretName "docker-registry-admin" }}
  secretRef: {{ coalesce .value.secretName "registry-admin" }}
  namespaces: ["*"]
{{- end }}
