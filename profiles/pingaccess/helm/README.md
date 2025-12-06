# Ping Access

## Helm

```console
helm upgrade --install pingaccess pingidentity/ping-devops --create-namespace --namespace pingfed -f pingaccess.yaml -f .\ingress.yaml
```
