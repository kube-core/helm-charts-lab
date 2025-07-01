{{ define "app-extensions.flux-imagepolicy" }}
{{ if eq .Values.flux.enabled true }}
{{ if eq .Values.flux.defaultImagePoliciesEnabled true }}
---
apiVersion: image.toolkit.fluxcd.io/v1beta1
kind: ImagePolicy
metadata:
  name: {{ .Values.name }}-default
  labels:
    {{- include "app.labels" . | nindent 4 }}
spec:
  imageRepositoryRef:
    name: {{ .Values.name }}
  policy:
    semver:
      range: "*"
---
apiVersion: image.toolkit.fluxcd.io/v1beta1
kind: ImagePolicy
metadata:
  name: {{ .Values.name }}-dev
  labels:
    {{- include "app.labels" . | nindent 4 }}
spec:
  imageRepositoryRef:
    name: {{ .Values.name }}
  filterTags:
    # Matches v-${commitHash}-${timestamp} with a named capture group (https://pkg.go.dev/regexp)
    pattern: '^v-(.*)-(?P<ts>.*)'
    extract: '$ts'
  policy:
    numerical:
      order: asc
---
apiVersion: image.toolkit.fluxcd.io/v1beta1
kind: ImagePolicy
metadata:
  name: {{ .Values.name }}-staging
  labels:
    {{- include "app.labels" . | nindent 4 }}
spec:
  imageRepositoryRef:
    name: {{ .Values.name }}
  policy:
    semver:
      range: ">=0.0.0-0"
---
apiVersion: image.toolkit.fluxcd.io/v1beta1
kind: ImagePolicy
metadata:
  name: {{ .Values.name }}-prod
  labels:
    {{- include "app.labels" . | nindent 4 }}
spec:
  imageRepositoryRef:
    name: {{ .Values.name }}
  policy:
    semver:
      range: ">=1.0.0"
{{ end }}


{{ if .Values.flux.imagePolicies }}
{{ range $k, $v := .Values.flux.imagePolicies }}
---
apiVersion: image.toolkit.fluxcd.io/v1beta1
kind: ImagePolicy
metadata:
  name: {{ include "app.fullname" $ }}-{{ $k }}
  labels:
    {{- include "app.labels" $ | nindent 4 }}
spec:
  imageRepositoryRef:
    name: {{ include "app.fullname" $ }}
{{ toYaml $v | indent 2 }}
{{ end }}

{{ end }}

{{ end }}
{{ end }}
