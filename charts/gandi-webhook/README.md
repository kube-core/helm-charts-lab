# gandi-webhook

A Helm chart for gandi-webhook.

## Usage

Install the helm chart repository:

```bash
helm repo add gandi-webhook https://sintef.github.io/gandi-webhook
```

Install the chart:

```bash
helm install gandi-webhook gandi-webhook/gandi-webhook -f gandiApiToken=XXX_EXAMPLE_XXX
```


## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| certManager.namespace | string | `"cert-manager"` | Namespace of cert-manager |
| certManager.serviceAccountName | string | `"cert-manager"` | Name of cert-manager's service account |
| containerport | int | `8443` | Container port (in case you have restrictions on the listening port) |
| features.apiPriorityAndFairness | bool | `true` | It is enabled by default since a while. |
| fullnameOverride | string | `""` | Set to override the fullname |
| gandiApiToken | string | `""` | The secret is not created if not set. |
| groupName | string | `"acme.bwolf.me"` | "Group is the API group name this server hosts", if you find this description helful. |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"ghcr.io/sintef/gandi-webhook"` | Image name |
| image.tag | string | `""` | Image tag (default to Chart's appVersion) |
| logLevel | int | `2` | Verbosity of the logs. Set to 6 for verbose logs. |
| nameOverride | string | `""` | Set to override the name |
| nodeSelector | object | `{}` |  |
| resources | object | `{}` |  |
| service.port | int | `443` | Service port |
| service.type | string | `"ClusterIP"` | Service type, e.g. ClusterIP, NodePort, LoadBalancer |
| tolerations | list | `[]` |  |

----------------------------------------------
