{{- define "app-extensions.scw-registry" -}}
{{- $name := (coalesce .value.name .key) }}
{{- $resourceName := (coalesce .value.resourceName .value.name .key) }}
apiVersion: registry.scaleway.upbound.io/v1alpha1
kind: RegistryNamespace
metadata:
  name: {{ $resourceName }}
  # annotations:
  #   crossplane.io/external-name: {{ coalesce .value.externalName $name }}
spec:
  deletionPolicy: {{ coalesce .value.deletionPolicy "Orphan" }}
  forProvider:
    name: {{ $resourceName }}
    region: {{ coalesce .value.region .common.cloud.location.region }}
    projectId: {{ coalesce .value.projectId .common.cloud.project }}
    isPublic: {{ (coalesce .value.isPublic) | default false }}
  providerConfigRef:
    name: upbound-scw
{{- end }}
