# PingFederate Token Exchange

PingFederate server profiles for OAuth2 token exchange implementation.

## Structure

- `pingfederate/` - Server profiles and Helm charts

## Quick Start

```bash
# Add Ping Helm repo
helm repo add pingidentity https://helm.pingidentity.com/
helm repo update

# Generate credentials
pingctl k8s generate devops-secret > devops.yaml
kubectl apply -f devops.yaml

# Deploy
helm upgrade --install pingfederate pingidentity/ping-devops \
  --create-namespace --namespace pingfed \
  -f pingfederate/helm/pingfederate.yaml \
  -f pingfederate/helm/ingress.yaml
```

## Details

See [pingfederate/README.md](pingfederate/README.md) for full documentation.

## Resources

- [PingFederate Docs](https://docs.pingidentity.com/pingfederate/)
- [Ping DevOps Helm Charts](https://helm.pingidentity.com/)
- [RFC 8693 - Token Exchange](https://datatracker.ietf.org/doc/html/rfc8693)
