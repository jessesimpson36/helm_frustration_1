{{- define "null_checking_bug.isPasswordExplicit" -}}
  {{- typeIs "string" .Values.existingSecret -}}
{{- end -}}

{{- define "null_checking_bug.isSecretName" -}}
  {{- and (typeIs "map[string]interface {}" .Values.existingSecret)
          (not (empty (get .Values.existingSecret "name"))) -}}
{{- end -}}


{{- define "null_checking_bug.evaluateNameOfSecret" -}}
  {{- if (include "null_checking_bug.isPasswordExplicit" .) -}}
    "default-secret"
  {{- else if (include "null_checking_bug.isSecretName" .) -}}
    {{- .Values.existingSecret.name | default "default-secret" }}
  {{- end }}
{{- end -}}
