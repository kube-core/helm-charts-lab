{{- define "app-extensions.scw-project" -}}
{{- $name := (coalesce .value.name .key) }}
{{- $resourceName := (coalesce .value.resourceName .value.name .key) }}
apiVersion: account.scaleway.upbound.io/v1alpha1
kind: Project
metadata:
  name: {{ $resourceName }}
  # annotations:
  #   crossplane.io/external-name: {{ coalesce .value.externalName $name }}
spec:
  deletionPolicy: {{ coalesce .value.deletionPolicy "Orphan" }}
  forProvider:
    name: {{ coalesce .value.externalName $name }}
    organizationId: {{ coalesce .value.organizationId .common.cloud.org.id }}
  providerConfigRef:
    name: upbound-scw
{{- end }}
