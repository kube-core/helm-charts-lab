{{- define "app-extensions.kube-ingress" -}}
{{ $values := .value }}
{{- $name := (coalesce $values.name .key) }}
{{- $resourceName := (coalesce $values.resourceName $values.name .key) }}
{{- $composition := .composition }}
{{- $namespace := (coalesce $composition.namespace $values.namespace "default") }}
{{- $domain := (coalesce $values.domain .common.cluster.config.domain) }}
{{- $subDomainBase := $namespace }}
{{- if $values.subDomainBase }}
{{- $subDomainBase = $values.subDomainBase }}
{{- end }}
{{- $nameTemplate := printf "%s.%s" $name $namespace -}}
{{- if eq $name $namespace }}
{{- $nameTemplate = $name }}
{{- end }}
{{- $host := (coalesce $values.host (printf "%s.%s.%s" (coalesce $values.subDomain $nameTemplate) $subDomainBase $domain)) }}
{{- if $values.subDomainOverride }}
{{- $host = (coalesce $values.host (printf "%s.%s" $values.subDomainOverride $domain)) }}
{{- end }}
{{- $path := (coalesce $values.path "/") }}
{{- $pathType := (coalesce $values.pathType "ImplementationSpecific") }}
{{- $hostPrefix := $values.hostPrefix }}
{{- if $hostPrefix }}
{{- $host = (printf "%s.%s" $hostPrefix $host) }}
{{- end }}

{{ $portName := coalesce $values.portName "http" }}
{{ $portNumber := coalesce $values.portNumber "8080" }}

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $resourceName }}
  namespace: {{ $namespace }}
  labels:
    {{- with $values.labels }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
  annotations:
    {{- include "app.annotations" . | nindent 4 }}
    {{- with $values.annotations }}
      {{- toYaml . | nindent 4 }}
    {{- end }}
    {{ if $values.serviceUpstream }}
    nginx.ingress.kubernetes.io/service-upstream: "true"
    {{ if $values.upstreamVhost }}
    nginx.ingress.kubernetes.io/upstream-vhost: "{{ $values.upstreamVhost }}"
    {{ else }}
    nginx.ingress.kubernetes.io/upstream-vhost: "{{ coalesce $values.serviceName $name }}.{{ $namespace }}.svc.cluster.local"
    {{ end }}
    {{ end }}
spec:
  ingressClassName: {{ coalesce $values.ingressClassName "nginx" }}
  {{- if ($values.tls) }}
  tls:
    - hosts:
      - {{ $host }}
      {{- if $values.customSecretName }}
      secretName: {{ $values.customSecretName }}
      {{- else }}
      secretName: {{ $host | replace "." "-" }}-tls
      {{- end }}
  {{- end }}
  rules:
  {{- if $values.defaultRules }}
  - host: {{ $host }}
    http:
      paths:
        - path: {{ $path }}
          pathType: {{ $pathType }}
          backend:
            service:
              name: {{ coalesce $values.serviceName $name }}
              port:
                {{- if $portName }}
                name: {{ $portName }}
                {{- else if $portNumber }}
                number: {{ $portNumber }}
                {{- end }}
  {{- end -}}
  {{- if $values.customRules }}
  {{- range $values.customRules }}
  - {{ toYaml . | nindent 4 | trim }}
  {{- end -}}
  {{- end -}}
{{- end -}}
