{{- define "app-extensions.scw-serviceaccountkey" -}}
{{- $name := (coalesce .value.name .key) }}
{{- $resourceName := (coalesce .value.resourceName .value.name .key) }}
apiVersion: iam.scaleway.upbound.io/v1alpha1
kind: ApiKey
metadata:
  name: {{ $resourceName }}
  # annotations:
  #   crossplane.io/external-name: {{ coalesce .value.externalName $name }}
spec:
  deletionPolicy: {{ coalesce .value.deletionPolicy "Orphan" }}
  forProvider:
    defaultProjectId: {{ coalesce .value.defaultProjectId .common.cloud.project }}
    applicationIdRef:
      name: {{ coalesce .value.serviceAccountName .value.externalName $name }}
    # name: {{ $resourceName }}
  publishConnectionDetailsTo:
    name: {{ coalesce .value.externalName $name }}
    {{- if .value.metadata }}
    metadata: {{ toYaml .value.metadata | nindent 6 }}
    {{ else }}
    metadata:
      annotations:
        replicator.v1.mittwald.de/replication-allowed: "true"
        replicator.v1.mittwald.de/replication-allowed-namespaces: "*"
    {{ end }}
  providerConfigRef:
    name: upbound-scw
{{- end }}
