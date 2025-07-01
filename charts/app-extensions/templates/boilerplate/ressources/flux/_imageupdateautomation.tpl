{{ define "app-extensions.flux-imageupdateautomation" }}
{{- $values := .value }}
{{- $common := .common }}
{{- $name := (coalesce $values.name .key) }}
{{- $resourceName := (coalesce $values.resourceName $values.name .key) }}
{{- $composition := .composition }}
{{- $namespace := (coalesce $composition.namespace $values.namespace "default") }}

{{- $interval := $values.interval }}
{{- $sourceRefName := coalesce $values.sourceRefName $name }}
{{- $sourceRefNamespace := coalesce $values.sourceRefNamespace $namespace }}
{{- $sourceRefKind := coalesce $values.sourceRefKind "GitRepository" }}
{{- $isGitSource := eq $sourceRefKind "GitRepository" }}
{{- $gitRef := $values.git.ref }}
{{- $gitAuthor := $values.git.author }}
{{- $gitMessageTemplate := $values.git.message }}
{{- $gitPush := $values.git.pushRef }}
{{- $update := $values.update }}

apiVersion: image.toolkit.fluxcd.io/v1beta1
kind: ImageUpdateAutomation
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
  interval: {{ $interval }}
  sourceRef:
    kind: {{ $sourceRefKind }}
    name: {{ $sourceRefName }}
    namespace: {{ $sourceRefNamespace }}
  {{ if $isGitSource }}
  git:
    checkout:
      ref: {{ toYaml $gitRef | nindent 8 }}
    commit:
      author: {{ toYaml $gitAuthor | nindent 8 }}
      messageTemplate: {{ $gitMessageTemplate | quote }}
    push: {{ toYaml $gitPush | nindent 6 }}
  update: {{ toYaml $update | nindent 4 }}
  {{ end }}

{{ end }}
