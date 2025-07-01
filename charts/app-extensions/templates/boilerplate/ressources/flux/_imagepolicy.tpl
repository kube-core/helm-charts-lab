{{ define "app-extensions.flux-imagepolicy" }}
{{- $values := .value }}
{{- $common := .common }}
{{- $name := (coalesce $values.name .key) }}
{{- $resourceName := (coalesce $values.resourceName $values.name .key) }}
{{- $composition := .composition }}
{{- $namespace := (coalesce $composition.namespace $values.namespace "default") }}

{{- $defaultSemverRange := "*" }}
{{- $devSemverRange := ">=0.0.0-0" }}
{{- $stagingSemverRange := ">=0.0.0-0" }}
{{- $prodSemverRange := ">=1.0.0" }}

{{- $semverRange := coalesce $values.semverRange $defaultSemverRange }}

{{- $filterTagsPattern := "^v-(.*)-(?P<ts>.*)" }}
{{- $filterTagsExtract := "$ts" }}

apiVersion: image.toolkit.fluxcd.io/v1beta1
kind: ImagePolicy
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
  imageRepositoryRef:
    name: {{ $name }}
  policy:
    semver:
      range: {{ $semverRange }}
{{ end }}
