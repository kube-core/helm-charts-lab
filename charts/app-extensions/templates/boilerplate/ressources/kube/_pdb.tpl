{{- define "app-extensions.kube-pdb" -}}
{{- $values := .value }}
{{- $common := .common }}
{{- $name := (coalesce $values.name .key) }}
{{- $resourceName := (coalesce $values.resourceName $values.name .key) }}
{{- $composition := .composition }}
{{- $namespace := (coalesce $composition.namespace $values.namespace "default") }}

{{- $deployment := index .composition "kube-deployment" }}
{{- $hpa := index .composition "kube-hpa" }}
{{- $replicas := coalesce $values.replicas $deployment.replicaCount }}
{{- $minReplicas := $hpa.minReplicas }}
{{- $hpaEnabled := $hpa.enabled }}
{{- $defaultMinAvailable := "50%" }}

{{- $targetReplicas := $replicas }}
{{- if (and $hpaEnabled (hasKey $hpa "minReplicas")) }}
{{- $targetReplicas = $minReplicas }}
{{- end }}

{{ $replicas2 := ge (int $targetReplicas) 2 }}

apiVersion: policy/v1
kind: PodDisruptionBudget
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
  selector:
    matchLabels:
      {{- include "app.selectorLabels" . | nindent 6 }}
  minAvailable: {{default (ternary $defaultMinAvailable 0 $replicas2) $values.minAvailable }}
{{ end }}
