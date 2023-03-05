{{- define "labels" }}
      tier: {{ .Values.labels.tier }}
      web: {{ .Values.labels.web }}
{{- end }}

{{- define "namespace" -}}
   {{ .Release.Name }}-{{ .Values.namespace }}
{{- end }}