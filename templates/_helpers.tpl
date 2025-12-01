{{- define "clickhouse-single.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "clickhouse-single.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "clickhouse-single.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "clickhouse-single.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" -}}
{{- end }}
