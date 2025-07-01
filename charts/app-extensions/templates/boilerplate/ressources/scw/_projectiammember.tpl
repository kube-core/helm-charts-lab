{{- define "app-extensions.scw-projectiammember" -}}
{{- $name := (coalesce .value.name .key) }}
{{- $resourceName := (coalesce .value.resourceName .value.name .key) }}
apiVersion: iam.scaleway.upbound.io/v1alpha1
kind: Policy
metadata:
  name: {{ $resourceName }}
  # annotations:
  #   crossplane.io/external-name: {{ coalesce .value.externalName $name }}
spec:
  deletionPolicy: {{ coalesce .value.deletionPolicy "Orphan" }}
  forProvider:
    name: {{ $resourceName }}
    organizationId: {{ coalesce .value.organizationId .common.cloud.org.id }}
    applicationIdRef:
      name: {{ coalesce .value.member $name }}
    rule:
      - organizationId: {{ coalesce .value.organizationId .common.cloud.org.id }}
        permissionSetNames:
          - ObjectStorageReadOnly
          {{ range $value := (.value.simpleRoles) }}
          {{ if eq $value "BucketAdmin"}}
          - ObjectStorageFullAccess
          {{ end }}
          {{ if eq $value "BucketRead"}}
          - ObjectStorageReadOnly
          - ObjectStorageObjectsRead
          - ObjectStorageBucketsRead
          {{ end }}
          {{ if eq $value "BucketWrite"}}
          - ObjectStorageBucketsWrite
          - ObjectStorageObjectsWrite
          {{ end }}
          {{ if eq $value "BucketDelete"}}
          - ObjectStorageBucketsDelete
          - ObjectStorageObjectsDelete
          {{ end }}
          {{ if eq $value "DNSAdmin"}}
          - DomainsDNSFullAccess
          {{ end }}
          {{ if eq $value "DNSRead"}}
          - DomainsDNSReadOnly
          {{ end }}
          {{ if eq $value "RegistryAdmin"}}
          - ContainerRegistryFullAccess
          {{ end }}
          {{ if eq $value "RegistryRead"}}
          - ContainerRegistryReadOnly
          {{ end }}
          {{ if eq $value "SecretAdmin"}}
          - SecretManagerFullAccess
          - SecretManagerSecretCreate
          - SecretManagerSecretDelete
          - SecretManagerSecretWrite
          {{ end }}
          {{ if eq $value "SecretRead"}}
          - SecretManagerReadOnly
          - SecretManagerSecretAccess
          {{ end }}
          {{ end }}
          {{ range $value := (.value.customRoles) }}
          - {{ . }}
          {{ end }}

    # member: serviceAccount:{{ $name }}@{{ $.common.cloud.project }}.iam.gserviceaccount.com
    # role: {{ coalesce .value.role (printf "projects/%s/roles/%s" $.common.cloud.project $name) }}
    # serviceAccountIdRef:
    #   name: {{ coalesce .value.sa $name }}
  providerConfigRef:
    name: upbound-scw
{{- end }}
