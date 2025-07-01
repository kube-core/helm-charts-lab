{{ define "app-extensions.flux-imagerepository" }}
{{- $values := .value }}
{{- $common := .common }}
{{- $name := (coalesce $values.name .key) }}
{{- $resourceName := (coalesce $values.resourceName $values.name .key) }}
{{- $composition := .composition }}
{{- $components := $composition.components }}
{{- $namespace := (coalesce $composition.namespace $values.namespace "default") }}

{{- $deployment := index $components "kube-deployment" }}

{{- $repository := coalesce $values.repository $deployment.image.repository }}
{{- $interval := $values.interval }}
{{- $secretName := $values.secretName }}

apiVersion: image.toolkit.fluxcd.io/v1beta1
kind: ImageRepository
metadata:
  name: {{ $resourceName }}
  namespace: {{ $namespace }}
  labels:
    {{- include "app.labels" . | nindent 4 }}
    {{- with $values.labels }}
      {{- toYaml . | nindent 4 | trim }}
    {{- end }}
  annotations:
  {{- include "app.annotations" . | nindent 4 }}
  {{- with $values.annotations }}
    {{ toYaml . | nindent 4 | trim }}
  {{- end }}
spec:
  image: {{ $repository }}
  interval: {{ $interval }}
  secretRef:
    name: {{ $secretName }}
{{ end }}
