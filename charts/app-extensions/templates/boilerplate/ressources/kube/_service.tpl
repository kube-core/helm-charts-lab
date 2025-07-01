{{ define "app-extensions.kube-service" }}
{{- $values := .value }}
{{- $common := .common }}
{{- $name := (coalesce $values.name .key) }}
{{- $resourceName := (coalesce $values.resourceName $values.name .key) }}
{{- $composition := .composition }}
{{- $components := $composition.components }}
{{- $namespace := (coalesce $composition.namespace $values.namespace "default") }}
{{- $name :=  $values.name }}

{{- $deployment := (index $components "kube-deployment") }}

{{- $portName := coalesce $values.portName $values.name "http" }}
{{- $targetPort := coalesce $values.targetPort $portName }}

apiVersion: v1
kind: Service
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
  type: {{ $values.type }}
  selector:
    {{- include "app.selectorLabels" . | nindent 4 }}
  ports:
    - port: {{ $values.port }}
      targetPort: {{ $targetPort }}
      protocol: TCP
      name: {{ $portName }}
  {{- if $deployment.metrics.enabled }}
    - port: {{ $deployment.metrics.port }}
      targetPort: metrics
      protocol: TCP
      name: metrics
  {{- end }}
  {{- range $values.additionalPorts }}
    - port: {{ .port }}
      name: {{ .name }}
      targetPort: {{ .name }}
      protocol: TCP
  {{- end }}
{{ end }}
