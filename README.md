# Null checking within a helm template is hard

## Premise

In a helm chart, it's typically an anti-pattern to see fields holding multiple possible types. But one such occurrence at one point was used by the bitnami helm charts.

```yaml
existingSecret: "in-line-password"  # aka string
```

```yaml
existingSecret:
  name: "name-of-k8s-secret" # aka map[string]interface {}
```

This sort of multiple typing for a single key can cause issues when performing null-checks. Because if you reference `.Values.existingSecret.name` inside a template, you'll get an error because `existingSecret` is `nil`.

The goal of this repository is to document and reproduce this problem, and document a solution to it as part of the `README.md` file.

## How to reproduce my issue?
Using the following command:

```bash
helm template test null_checking_bug --set existingSecret=jesse
```

I also have a `Makefile` which will run 3 scenarios:
1. No existingSecret provided
2. existingSecret provided
3. existingSecret.name provided



You'll see this error.

```
Error: template: null_checking_bug/templates/secret.yaml:7:40: executing "null_checking_bug/templates/secret.yaml" at <.Values.existingSecret.name>: can't evaluate field name in type interface {}

Use --debug flag to render out invalid YAML
```


## What are my findings?


### Null checks don't work in yaml templates

When I have
```gotmpl
  {{- if (include "null_checking_bug.isSecretName" .) -}}
  nameOfSecretFromValuesYaml: {{ .Values.existingSecret.name }}
  {{- end }}
```
inside my `secret.yaml`, despite isSecretName evaluating to `false`, I still get the error 

```
Error: template: null_checking_bug/templates/secret.yaml:7:40: executing "null_checking_bug/templates/secret.yaml" at <.Values.existingSecret.name>: can't evaluate field name in type interface {}

Use --debug flag to render out invalid YAML
```
but if I remove those 3 lines, I get this output:

```yaml
helm template test null_checking_bug
---
# Source: null_checking_bug/templates/secret.yaml
apiVersion: v1
data:
  isSecretName: "false"
  isPasswordExplicit: "false"
  nameOfSecret: "default-secret"
kind: Secret
metadata:
  name: jesse-frustration
  namespace: default
type: Opaque
helm template test null_checking_bug --set existingSecret=jesse
---
# Source: null_checking_bug/templates/secret.yaml
apiVersion: v1
data:
  isSecretName: "false"
  isPasswordExplicit: "true"
  nameOfSecret: "default-secret"
kind: Secret
metadata:
  name: jesse-frustration
  namespace: default
type: Opaque
helm template test null_checking_bug --set existingSecret.name=jesse
---
# Source: null_checking_bug/templates/secret.yaml
apiVersion: v1
data:
  isSecretName: "jesse"
  isPasswordExplicit: "false"
  nameOfSecret: "default-secret"
kind: Secret
metadata:
  name: jesse-frustration
  namespace: default
type: Opaque

```


### Finding 2: nameOfSecret is not evaluating to .Values.existingSecret.name despite being not nil

See 3rd yaml in the previous finding..
```yaml

helm template test null_checking_bug --set existingSecret.name=jesse
---
# Source: null_checking_bug/templates/secret.yaml
apiVersion: v1
data:
  isSecretName: "jesse"
  isPasswordExplicit: "false"
  nameOfSecret: "default-secret"
kind: Secret
metadata:
  name: jesse-frustration
  namespace: default
type: Opaque

```
