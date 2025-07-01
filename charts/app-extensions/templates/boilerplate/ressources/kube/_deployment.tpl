{{- define "app-extensions.kube-deployment" -}}
{{- $values := .value }}
{{- $common := .common }}
{{- $name := (coalesce $values.name .key) }}
{{- $resourceName := (coalesce $values.resourceName $values.name .key) }}
{{- $composition := .composition }}
{{- $components := $composition.components }}
{{- $namespace := (coalesce $composition.namespace $values.namespace "default") }}
{{- $version := coalesce .value.version $values.image.digest $values.image.tag $common.release.appVersion }}
{{- $containerName := coalesce $values.containerName $name }}

{{- $deployment := index $components "kube-deployment" }}
{{- $hpa := index $components "kube-hpa" }}
{{- $service := index $components "kube-service" }}

{{- $servicePort := coalesce $service.port $service.targetPort }}

{{- $defaultImagePolicy := (printf "%s:%s-%s" $namespace ($name) (coalesce $values.defaultImagePolicy "default")) }}
{{- $imagePolicy := coalesce $values.imagePolicy $defaultImagePolicy }}
{{- $useReplicas := and (not $hpa.enabled) (not $values.disableReplicas) }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $resourceName }}
  namespace: {{ $namespace }}
  labels:
    {{- if (eq $values.logging.enabled true) }}
    logging.kube-core.io/flow-name: app
    {{- end }}
    {{- include "app.labels" . | nindent 4 }}
    {{- with $values.labels }}
    {{- toYaml . | nindent 4 | trim }}
    {{- end }}
  annotations:
    flux.kube-core.io/imagepolicy: "{{ $imagePolicy }}"
    {{- include "app.annotations" . | nindent 4 }}
    {{- with $values.annotations }}
    {{ toYaml . | nindent 4 | trim }}
    {{- end }}
spec:
  {{- with  $values.progressDeadlineSeconds }}
  progressDeadlineSeconds: {{ . | quote }}
  {{- end }}
  {{- with  $values.minReadySeconds }}
  minReadySeconds: {{ . | quote }}
  {{- end }}
  {{- if $useReplicas }}
  replicas: {{ $values.replicaCount }}
  {{- end }}
  {{- if $values.strategy }}
  strategy:
    {{- toYaml $values.strategy | nindent 4 }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "app.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- if (eq $values.logging.enabled true) }}
        logging.kube-core.io/flow-name: app
        {{- end }}
        {{- include "app.labels" . | nindent 8 }}
        {{- with $values.pod.labels }}
        {{- toYaml . | nindent 8 | trim }}
        {{- end }}
      annotations:
        flux.kube-core.io/imagepolicy: "{{ $imagePolicy }}"
        {{- include "app.annotations" . | nindent 8 }}
        {{- with $values.pod.annotations }}
        {{ toYaml . | nindent 8 | trim }}
        {{- end }}
    spec:
      {{- with $values.image.pullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if $values.securityContext }}
      securityContext:
        {{- toYaml $values.securityContext | nindent 8 }}
      {{ end }}
      {{- with $values.scheduling.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $values.scheduling.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $values.scheduling.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
      - name: {{ $containerName }}
        {{- if $values.pod.securityContext }}
        securityContext:
          {{- toYaml $values.pod.securityContext | nindent 12 }}
        {{- end }}
        {{- if $values.image.digest }}
        image: {{ $values.image.repository }}@{{ $values.image.digest }}
        {{- else }}
        image: {{ $values.image.repository }}:{{ $version }} # {"$imagepolicy": "{{ $imagePolicy }}"}
        {{- end }}
        imagePullPolicy: {{ $values.image.pullPolicy }}
        {{- if $values.pod.workingDir }}
        workingDir: {{ $values.pod.workingDir }}
        {{- end }}
        {{- if $values.pod.command }}
        command:
        {{- range $values.pod.command }}
        - {{ . | quote }}
        {{- end }}
        {{- end }}
        {{- if $values.pod.args }}
        args:
        {{- range $values.pod.args }}
        - {{ . | quote }}
        {{- end }}
        {{- end }}
        ports:
        - name: http
          containerPort: {{ $servicePort }}
          protocol: TCP
        {{- if $values.metrics.enabled }}
        - name: metrics
          containerPort: {{ $values.metrics.port }}
          protocol: TCP
        {{- end }}
        {{- range $service.additionalPorts }}
        - name: {{ .name }}
          containerPort: {{ default .port .targetPort }}
          protocol: TCP
        {{- end }}
        {{- if $values.resources }}
        resources:
          {{- toYaml $values.resources | nindent 12 }}
        {{- end }}
        {{- if and $values.healthCheck.enabled $values.healthCheck.liveness.enabled }}
        livenessProbe:
          {{- if or $values.healthCheck.tcpSocket $values.healthCheck.liveness.tcpSocket }}
          tcpSocket:
            port: {{ default ( default $service.port $values.healthCheck.port ) $values.healthCheck.liveness.port  }}
          {{- else }}
          httpGet:
            path: {{ default $values.healthCheck.path $values.healthCheck.liveness.path }}
            port: {{ default ( default $service.port $values.healthCheck.port ) $values.healthCheck.liveness.port  }}
          {{- end }}
          initialDelaySeconds: {{ default $values.healthCheck.initialDelaySeconds $values.healthCheck.liveness.initialDelaySeconds }}
          periodSeconds: {{ default $values.healthCheck.periodSeconds $values.healthCheck.liveness.periodSeconds }}
          timeoutSeconds: {{ default $values.healthCheck.timeoutSeconds $values.healthCheck.liveness.timeoutSeconds }}
          failureThreshold: {{ default $values.healthCheck.failureThreshold $values.healthCheck.liveness.failureThreshold }}
        {{- end }}
        {{- if and $values.healthCheck.enabled $values.healthCheck.readiness.enabled }}
        readinessProbe:
          {{- if or $values.healthCheck.tcpSocket $values.healthCheck.readiness.tcpSocket }}
          tcpSocket:
            port: {{ default ( default $service.port $values.healthCheck.port ) $values.healthCheck.readiness.port  }}
          {{- else }}
          httpGet:
            path: {{ default $values.healthCheck.path $values.healthCheck.readiness.path }}
            port: {{ default ( default $service.port $values.healthCheck.port ) $values.healthCheck.readiness.port  }}
          {{- end }}
          initialDelaySeconds: {{ default $values.healthCheck.initialDelaySeconds $values.healthCheck.readiness.initialDelaySeconds }}
          periodSeconds: {{ default $values.healthCheck.periodSeconds $values.healthCheck.readiness.periodSeconds }}
          timeoutSeconds: {{ default $values.healthCheck.timeoutSeconds $values.healthCheck.readiness.timeoutSeconds }}
          failureThreshold: {{ default $values.healthCheck.failureThreshold $values.healthCheck.readiness.failureThreshold }}
        {{- end }}
        {{- if (and ($values.pod.envFrom.enabled) (or $values.pod.envFrom.configmaps $values.pod.envFrom.secrets)) }}
        envFrom:
        {{- range $values.pod.envFrom.configmaps }}
        - configMapRef:
            name: {{ . }}
        {{- end }}
        {{- range $values.pod.envFrom.secrets }}
        - secretRef:
            name: {{ . }}
        {{- end }}
        {{- end }}
        {{- if or $values.pod.env.values $values.pod.env.secrets $values.pod.env.valuesMap  $values.pod.additionalEnv.values $values.pod.additionalEnv.secrets $values.pod.additionalEnv.valuesMap }}
        env:
        {{- range $values.pod.env.values  }}
        - name: {{ .name }}
          value: "{{ .value }}"
        {{- end }}
        {{- range $values.pod.env.secrets }}
        - name: {{ default .secretKey .name }}
          valueFrom:
            secretKeyRef:
              name: {{ .secretName }}
              key: {{ .secretKey }}
              optional: {{ .optional | default false }}
        {{- end }}
        {{- if $values.pod.env.valuesMap }}
          {{- range $k, $v := $values.pod.env.valuesMap }}
        - name: {{ $k }}
          value: {{ $v | quote }}
          {{- end }}
        {{- end }}
        {{- range $values.pod.additionalEnv.values }}
        - name: {{ .name }}
          value: "{{ .value }}"
        {{- end }}
        {{- range $values.pod.additionalEnv.secrets }}
        - name: {{ default .secretKey .name }}
          valueFrom:
            secretKeyRef:
              name: {{ .secretName }}
              key: {{ .secretKey }}
              optional: {{ .optional | default false }}
        {{- end }}
        {{- if $values.pod.additionalEnv.valuesMap }}
        {{- range $k, $v := $values.pod.additionalEnv.valuesMap }}
        - name: {{ $k }}
          value: {{ $v | quote }}
        {{- end }}
        {{- end }}
        {{- end }}
        {{- if or $values.pod.mounts.configMap $values.pod.mounts.secrets $values.pod.mounts.configMapMap }}
        volumeMounts:
        {{- end }}
        {{- range $values.pod.mounts.configMap }}
        - name: {{ .name }}
          mountPath: {{ .mountPath }}
          {{- with .subPath }}
          subPath: {{ . }}
          {{- end }}
          readOnly: {{ .readOnly | default "true" }}
        {{- end }}
        {{- range $values.pod.mounts.secrets }}
        - name: {{ .name }}
          mountPath: {{ .mountPath }}
          readOnly: {{ .readOnly | default "true" }}
        {{- end }}
        {{- if $values.pod.mounts.configMapMap }}
        {{- range $k, $v := $values.pod.mounts.configMapMap }}
        - name: {{ $k }}
          mountPath: {{ $v }}
        {{- end }}
        {{- end }}
      {{- if $values.initContainer.enabled }}
      initContainers:
      - name: {{ $containerName }}-init
        {{ $imagePolicy := printf "%s:%s" $namespace ($name) }}
        {{- if $values.image.digest }}
        image: {{ $values.image.repository }}@{{ $values.image.digest }}
        {{- else }}
        image: {{ $values.image.repository }}:{{ $version }} # {"$imagepolicy": "{{ $imagePolicy }}"}
        {{- end }}
        {{- if $values.pod.workingDir }}
        workingDir: {{ $values.pod.workingDir }}
        {{- end }}
        command:
        {{- range $values.initContainer.command }}
        - {{ . | quote }}
        {{- end }}
        env:
        {{- if $values.pod.env }}
        {{- range $values.pod.env.values }}
        - name: {{ .name }}
          value: "{{ .value }}"
        {{- end }}
        {{- range $values.pod.env.secrets }}
        - name: {{ default .secretKey .name }}
          valueFrom:
            secretKeyRef:
              name: {{ .secretName }}
              key: {{ .secretKey }}
        {{- end }}
        {{- end }}
        {{- if $values.initContainer.resources }}
        resources:
          {{ toYaml $values.initContainer.resources | indent 10 | trim }}
        {{- end }}
      {{- end }}
      {{- if or $values.pod.mounts.configMap $values.pod.mounts.secrets $values.pod.mounts.configMapMap }}
      volumes:
      {{- end }}
      {{- range $values.pod.mounts.configMap }}
      - name: {{ .name }}
        configMap:
          name: {{ .name }}
      {{- end }}
      {{- range $values.pod.mounts.secrets }}
      - name: {{ .name }}
        secret:
          secretName: {{ .secretName }}
          defaultMode: {{ .defaultMode | default "256" }}
      {{- end }}
      {{- if $values.pod.mounts.configMapMap }}
      {{- range $k, $v := $values.pod.mounts.configMapMap }}
      - name: {{ $k }}
        configMap:
          name: {{ $k }}
      {{- end }}
      {{- end }}
{{- end }}
