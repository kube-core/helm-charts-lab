
apiVersion: image.toolkit.fluxcd.io/v1beta1
kind: ImageRepository
metadata:
  name: {{ .Values.name }}
  labels:
    {{- include "app.labels" . | nindent 4 }}
spec:
  image: {{ .Values.image.repository }}
  interval: {{ .Values.flux.imageRepository.interval }}
  secretRef:
    name: {{ .Values.flux.imageRepository.secretName }}
