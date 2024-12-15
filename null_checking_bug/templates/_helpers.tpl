{{- define "null_checking_bug.isPasswordExplicit" -}}
  {{- if typeIs "string" .Values.existingSecret -}}
true
  {{- else -}}
false
  {{- end -}}
{{- end -}}

{{- define "null_checking_bug.isSecretName" -}}
  {{- if and (typeIs "map[string]interface {}" .Values.existingSecret)
          (get .Values.existingSecret "name") -}}
true
  {{- else -}}
false
  {{- end -}}
{{- end -}}


{{- define "null_checking_bug.evaluateNameOfSecret" -}}
  {{- if eq "true" (include "null_checking_bug.isPasswordExplicit" .) -}}
    "default-secret"
  {{- else if eq "true" (include "null_checking_bug.isSecretName" .) -}}
    {{- .Values.existingSecret.name | default "replace-default-secret" | quote }}
  {{- end }}
{{- end -}}
