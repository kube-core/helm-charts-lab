{{- define "app-extensions.patch-scwapikey" -}}
{{- $name := (coalesce .value.name .key) }}
{{- $resourceName := (coalesce .value.resourceName .value.name .key) }}

apiVersion: redhatcop.redhat.io/v1alpha1
kind: Patch
metadata:
  name: {{ $name }}
spec:
  serviceAccountRef:
    name: {{ .common.patch.serviceAccountName }}
  patches:
    path-scw-api-key-secret:
      targetObjectRef:
        apiVersion: v1
        kind: Secret
        name: {{ coalesce .value.appName $name }}
      patchTemplate: |
      {{ $registryEndpoint := (coalesce .common.cloud.registry.hostname (printf "rg.%s-%s.scw.cloud" .common.cloud.location.region .common.cloud.location.zone) )}}
      {{ $registryNamespace := (coalesce .common.cloud.registry.namespace (printf "%s-%s" .common.cloud.projectName .common.cluster.config.name) ) }}
      {{ $registryUser := (printf "%s/%s" $registryEndpoint $registryNamespace) }}
        stringData:
          access_key: {{ `{{ (index . 1).status.atProvider.accessKey }}` }}
          secret_key: {{ `{{ index (index . 0).data "attribute.secret_key" | b64dec }}` }}
          scw_access_key: {{ `{{ (index . 1).status.atProvider.accessKey }}` }}
          scw_secret_key: {{ `{{ index (index . 0).data "attribute.secret_key" | b64dec }}` }}
          registry_endpoint: {{ $registryEndpoint }}
          registry_namespace: {{ $registryNamespace }}
          registry_user: {{ $registryUser }}
          registry_auth: {{ $registryUser }}:{{ `{{ index (index . 0).data "attribute.secret_key" | b64dec }}` }}
          cloud: |
            [default]
            aws_access_key_id={{ `{{ (index . 1).status.atProvider.accessKey }}` }}
            aws_secret_access_key={{ `{{ index (index . 0).data "attribute.secret_key" | b64dec }}` }}
      patchType: application/merge-patch+json
      sourceObjectRefs:
      - apiVersion: iam.scaleway.upbound.io/v1alpha1
        kind: ApiKey
        name: {{ coalesce .value.appName $name }}
{{- end }}
