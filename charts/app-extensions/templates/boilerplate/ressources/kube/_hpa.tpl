{{ define "app-extensions.kube-hpa" }}
{{- $values := .value }}
{{- $common := .common }}
{{- $name := (coalesce $values.name .key) }}
{{- $resourceName := (coalesce $values.resourceName $values.name .key) }}
{{- $composition := .composition }}
{{- $namespace := (coalesce $composition.namespace $values.namespace "default") }}

{{- $deployment := (index .composition "kube-deployment") }}
{{- $maxReplicas := coalesce $values.maxReplicas 10 }}
{{- $minReplicas := coalesce $values.minReplicas $deployment.replicaCount 1 }}
{{- $scaleTargetRefName := coalesce $values.scaleTargetRefName $resourceName }}

apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
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
  maxReplicas: {{ $maxReplicas }}
  minReplicas: {{ $minReplicas }}
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ $scaleTargetRefName }}
  metrics:
  {{- if $values.cpu }}
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: {{ $values.cpu }}
  {{- end }}
  {{- if $values.memory }}
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: {{ $values.memory }}
  {{- end }}
  {{- if $values.behavior }}
  behavior: {{ toYaml $values.behavior | nindent 4 }}
  {{- else }}
  behavior:
    scaleDown:
      selectPolicy: Min # The policy that affects the least amount of pods is selected (=> scale down slower)
      stabilizationWindowSeconds: 300 # 5 minutes before scale down
      policies:
      # Can remove 50% of pods every minute
      - periodSeconds: 60
        type: Percent
        value: 50
      # Can remove 5 pods every 30 seconds
      - type: Pods
        value: 5
        periodSeconds: 30
    scaleUp:
      selectPolicy: Max # The policy that affects the max amount of pods is selected (=> scale up faster)
      stabilizationWindowSeconds: 0 # Instant scale up
      policies:
      # Can double the amount of pods every 10 seconds
      - periodSeconds: 10
        type: Percent
        value: 100
      # Can add 5 pods every 10 seconds
      - periodSeconds: 10
        type: Pods
        value: 5
{{- end }}
{{- end }}
