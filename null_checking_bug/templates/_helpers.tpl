

{{- define "null_checking_bug.evaluateNameOfSecret" -}}
{{- $isSecretName := and (typeIs "map[string]interface {}" .Values.existingSecret)
          (get .Values.existingSecret "name") -}}
{{- $isPasswordExplicit := (typeIs "string" .Values.existingSecret) }}
  {{- if $isPasswordExplicit -}}
    "default-secret"
  {{- else if $isSecretName -}}
    {{- .Values.existingSecret.name | default "default-secret" }}
  {{- end }}
{{- end -}}
