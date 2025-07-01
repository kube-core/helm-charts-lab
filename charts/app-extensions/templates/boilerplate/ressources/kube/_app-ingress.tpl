{{- define "app-extensions.app-ingress" }}
{{- $values := .value }}
{{- $common := .common }}
{{- $name := (coalesce $values.name .key) }}
{{- $resourceName := (coalesce $values.resourceName $values.name .key) }}
{{- $composition := .composition }}
{{- $components := $composition.components }}
{{- $namespace := (coalesce $composition.namespace $values.namespace "default") }}

{{- $service := dict }}
{{- if $components }}
{{- $service = index $components "kube-service" }}
{{- end }}

{{- $defaultServicePort := "80" }}
{{- $maintenanceModeEnabled := $composition.config.maintenanceMode.enabled | default false }}
{{- $blueGreenModeEnabled := $composition.config.blueGreenMode.enabled | default false }}
{{- $isMain := eq $values.type "main" }}
{{- $portName := coalesce $values.portName $service.name }}
{{- $portNumber := coalesce $values.portNumber $service.port $defaultServicePort }}
{{- $serviceName := coalesce $values.serviceName $name }}
{{- $useDefaultAppIngress := coalesce $values.default true }}
{{- $ingressPath := coalesce $values.path "/" }}
{{- $pathType := coalesce $values.pathType "ImplementationSpecific" }}



{{- if $useDefaultAppIngress }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $resourceName }}
  namespace: {{ $namespace }}
  {{- include "app.ingress-metadata" . | nindent 2 }}
spec:
  ingressClassName: {{ $values.className }}
  {{- if $values.host }}
  rules:
  - host: {{ $values.host }}
    http:
      paths:
      - backend:
          service:
            name: {{ $serviceName }}
            port:
              {{- if $portName }}
              name: {{ $portName }}
              {{- else if $portNumber }}
              number: {{ $portNumber }}
              {{- end }}
        path: {{ $ingressPath | quote }}
        pathType: {{ $pathType }}
  tls:
  - hosts:
    - {{ $values.host }}
    secretName: {{ (printf "%s-tls-cert" $values.host) | replace "." "-" }}
{{- end }}

{{- end }}
{{- end }}
