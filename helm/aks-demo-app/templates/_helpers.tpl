{{- define "aks-demo-app.name" -}}
aks-demo-app
{{- end -}}

{{- define "aks-demo-app.fullname" -}}
{{- if .Release.Name -}}
{{ .Release.Name }}
{{- else -}}
{{ include "aks-demo-app.name" . }}
{{- end -}}
{{- end -}}

{{- define "aks-demo-app.labels" -}}
app.kubernetes.io/name: {{ include "aks-demo-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}