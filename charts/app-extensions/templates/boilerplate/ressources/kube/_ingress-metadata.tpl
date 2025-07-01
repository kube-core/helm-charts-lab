{{- define "app.ingress-metadata"}}
{{- $values := .value }}
{{- $isMain := eq $values.type "main" }}
labels:
{{- include "app.labels" . | nindent 2 }}
{{- with $values.labels }}
  {{- toYaml . | nindent 2 }}
{{- end }}
  {{- if $values.options.accessFiltered }}
  ingress.neo9.io/access-filtered: {{ $values.options.accessFiltered | quote }}
  {{- end }}
annotations:
{{- include "app.annotations" . | nindent 2 }}
{{- with $values.annotations }}
  {{- toYaml . | nindent 2 }}
{{- end }}
  {{- if $values.options.allowedVisitors }}
  {{- if $isMain }}
  ingress.neo9.io/allowed-visitors: {{ $values.options.allowedVisitors | quote  }}
  {{ else }}
  ingress.neo9.io/allowed-visitors: {{ $values.options.previewVisitors | quote  }}
  {{- end }}
  {{- end }}
  {{- if $values.options.accessFiltered }}
  ingress.neo9.io/access-filtered: {{ $values.options.accessFiltered | quote }}
  {{- end }}
  {{- if $values.options.autoDiscover }}
  exposeIngressUrl: "globally"
  forecastle.stakater.com/expose: "true"
  {{- end }}
  {{- if $values.options.clusterIssuer }}
  cert-manager.io/cluster-issuer: {{ $values.options.clusterIssuer | quote  }}
  {{- end }}
  {{- if $values.options.ttl }}
  external-dns.alpha.kubernetes.io/ttl: {{ $values.options.ttl | quote  }}
  {{- end }}
  {{- if $values.globalEasyTls }}
  nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
  nginx.ingress.kubernetes.io/ssl-redirect: "true"
  {{- end }}
  {{- if $values.options.proxyBodySize }}
  nginx.ingress.kubernetes.io/proxy-body-size: "200m"
  {{- end }}
  {{- if $values.options.serviceUpstream }}
  nginx.ingress.kubernetes.io/service-upstream: {{ $values.options.serviceUpstream | quote }}
  {{- end }}
  {{- if $values.options.upstreamVhost }}
  nginx.ingress.kubernetes.io/upstream-vhost: {{ $values.options.upstreamVhost | quote }}
  {{- end }}
  {{- if $values.options.mergeable }}
  nginx.org/mergeable-ingress-type: {{ $values.options.mergeableType | quote }}
  {{- end }}
{{- end }}
