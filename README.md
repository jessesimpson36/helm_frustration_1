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

You'll see this error.

```
Error: template: null_checking_bug/templates/secret.yaml:7:40: executing "null_checking_bug/templates/secret.yaml" at <.Values.existingSecret.name>: can't evaluate field name in type interface {}

Use --debug flag to render out invalid YAML
```


## What is my finding?


