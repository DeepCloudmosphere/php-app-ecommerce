{{- define "labels" }}
      tier: {{ .Values.labels.tier }}
      web: {{ .Values.labels.web }}
{{- end }}

{{- define "namespace" -}}
   {{ .Release.Name }}-{{ .Values.namespace }}
{{- end }}

#### network policy labels

{{- define "networkPolicyLabels" }}
    tier: {{ .Values.networkPolicy.podSelectorLabels.tier }}
    web: {{ .Values.networkPolicy.podSelectorLabels.web }}
{{- end }}

{{- define "networkPolicyIngressLabels" }}
    tier: {{ .Values.networkPolicy.ingress.podSelectorLabels.tier }}
    web: {{ .Values.networkPolicy.ingress.podSelectorLabels.web }}
{{- end }}