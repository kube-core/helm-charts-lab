{{- define "app-extensions.scw-bucket" -}}
{{- $name := (coalesce .value.name .key) }}
{{- $resourceName := (coalesce .value.resourceName .value.name .key) }}
apiVersion: object.scaleway.upbound.io/v1alpha1
kind: Bucket
metadata:
  name: {{ $resourceName }}
  # annotations:
  #   crossplane.io/external-name: {{ coalesce .value.externalName $name }}
spec:
  deletionPolicy: {{ coalesce .value.deletionPolicy "Orphan" }}
  forProvider:
    projectId: {{ coalesce .value.projectId .common.cloud.project }}
    name: {{ coalesce .value.externalName $name }}
    tags:
      managed-by: "crossplane"
      cluster: {{ .common.cluster.config.name }}
      {{- if .value.labels }}
      {{ toYaml (.value.labels) | nindent 4 }}
      {{- end }}
  providerConfigRef:
    name: upbound-scw
{{- end }}
