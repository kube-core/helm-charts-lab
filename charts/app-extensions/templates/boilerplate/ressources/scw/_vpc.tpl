{{- define "app-extensions.scw-vpc" -}}
{{- $name := (coalesce .value.name .key) }}
{{- $resourceName := (coalesce .value.resourceName .value.name .key) }}
apiVersion: vpc.scaleway.upbound.io/v1alpha1
kind: VPC
metadata:
  name: {{ $resourceName }}
  # annotations:
  #   crossplane.io/external-name: {{ coalesce .value.externalName $name }}
spec:
  deletionPolicy: {{ coalesce .value.deletionPolicy "Orphan" }}
  forProvider:
    name: {{ coalesce .value.externalName $name }}
    region: {{ coalesce .value.region .common.cloud.location.region }}
    projectId: {{ coalesce .value.projectId .common.cloud.project }}
  providerConfigRef:
    name: upbound-scw
{{- end }}
