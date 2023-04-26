{{- $componet := include "kafka.broker.componet" . }}
{{- $replicaCount := .Values.broker.replicaCount | int }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "kafka.broker.fullname" . }}
  labels:
    {{- include "kafka.labels" $ | nindent 4 }}
    component: {{ $componet | quote }}
data:
  entrypoint.sh: |
