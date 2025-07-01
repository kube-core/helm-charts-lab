{{- define "app-extensions.add-release-metadata-to-values" -}}
{{ $metadata := dict "name" .Release.Name "namespace" .Release.Namespace "chartVersion" .Chart.Version "chartName" .Chart.Name "appVersion" (.Chart.AppVersion | trunc 63 | trimSuffix "-")  }}
{{ $_ := set .Values "release" $metadata }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "app.chart" -}}
{{- printf "%s-%s" .common.release.chartName .common.release.chartVersion | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "app.labels" -}}
{{ include "app.selectorLabels" . }}
{{- if .value.image }}
app.kubernetes.io/version: {{ (coalesce .value.version .value.image.digest .value.image.tag .common.release.appVersion) | quote }}
{{- else if .composition }}
{{ $deployment := index .composition.components "kube-deployment"}}
app.kubernetes.io/version: {{ (coalesce .composition.version $deployment.image.digest $deployment.image.tag .common.release.appVersion) | quote }}
{{- end }}
app.kubernetes.io/managed-by: Helm
helm.sh/chart: {{ include "app.chart" . }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "app.annotations" -}}
meta.helm.sh/release-name: {{ coalesce .common.release.name }}
meta.helm.sh/release-namespace: {{ coalesce .namespace .value.namespace .common.release.namespace }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "app.selectorLabels" -}}
app.kubernetes.io/instance: {{ coalesce .instance .common.release.name }}
{{- if .composition}}
app.kubernetes.io/name: {{ coalesce .name .value.name .composition.name .common.release.name }}
{{- else }}
app.kubernetes.io/name: {{ coalesce .name .value.name .common.release.name }}
{{- end }}
{{- end }}




{{- define "app-extensions.include.resources" -}}
{{- $baseValues := .baseValues }}
{{- $resourceType := .resourceType }}
{{- $resourceTypePlural := .resourceTypePlural }}

{{- range $kindName, $kindList := (index $baseValues $resourceTypePlural) }}
{{- $kindName = ($kindName | lower) }}
{{- range $resourceKey, $resourceConfig := $kindList }}
{{- if (index $baseValues $resourceType $kindName) }}
{{- include "app-extensions.include.resource" (dict "baseValues" $baseValues "kindName" $kindName "resourceType" $resourceType "resourceTypePlural" $resourceTypePlural "resourceKey" $resourceKey "resourceConfig" $resourceConfig) }}

{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "app-extensions.include.composition" -}}

{{- end }}

{{- define "app-extensions.include.component" -}}
{{- $baseValues := .baseValues }}
{{- $resourceType := "resource" }}
{{- $resourceTypePlural := "resources" }}
{{- $resourceKey := .resourceKey }}
{{- $resourceConfig := .resourceConfig }}
{{- $composition := .composition }}
{{- $kindName := (coalesce .kindName $resourceKey) }}

{{- include "app-extensions.include.resource" (dict "baseValues" $baseValues "kindName" $kindName "resourceType" $resourceType "resourceTypePlural" $resourceTypePlural "resourceKey" $resourceKey "resourceConfig" $resourceConfig "composition" $composition) }}
{{- end }}


{{- define "app-extensions.include.resource" -}}
{{- $baseValues := .baseValues }}
{{- $resourceType := .resourceType }}
{{- $resourceTypePlural := .resourceTypePlural }}
{{- $resourceKey := .resourceKey }}
{{- $resourceConfig := .resourceConfig }}
{{- $composition := .composition }}
{{- $kindName := (coalesce .kindName $resourceKey) }}

{{- $resource := (dict) }}
{{- $resource = dict "key" $resourceKey "value" (mustMergeOverwrite (deepCopy (index $baseValues $resourceType $kindName)) (deepCopy $resourceConfig)) }}

{{- $globalpick := pick $baseValues "patch" "cloud" "cluster" "release" }}
{{- $commonvalues := dict "common" $globalpick "baseValues" $baseValues "composition" $composition }}
{{- $mergedvalues := deepCopy $commonvalues | mergeOverwrite $resource }}

{{- if $resource.value.enabled }}
---
{{- include (printf "app-extensions.%s" ($kindName | kebabcase)) $mergedvalues }}
{{- end }}
{{- end }}


{{- define "app-extensions.include.dump" -}}
{{- if .Values.dump.enabled }}
{{ $status := coalesce .Values.dump.status "dump" }}
{{ $releaseId := printf "%s/%s/%s" .Release.Context .Release.Namespace .Release.Name }}
---
kind: ConfigMap
apiVersion: v1
metadata:
  name: {{ .Release.Name }}-{{ $status }}
  namespace: {{ .Release.Namespace }}
data:
  releaseId: "{{ $releaseId }}"
  status: "{{ $status }}"
  message: "{{ .Values.dump.message }}"
  values.yaml: |
    resources: {{ toYaml .Values | nindent 6 }}
{{- end }}
{{- end }}
