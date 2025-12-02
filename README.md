# PingFederate Token Exchange

PingFederate server profiles for OAuth2 token exchange implementation.

## Structure

- `profiles/pingfederate/` - Server profiles and Helm charts
- `docker/` - Custom PingFederate Docker image with adapters (PingID, PingOne MFA)
- `lambda/` - AWS Lambda functions for headless auth flow (OAuth2 with OTP)
- `docker/terraform-init/` - Infrastructure-as-Code for PingFederate resources

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

## Component Documentation

### PingFederate Configuration

See [profiles/pingfederate/README.md](profiles/pingfederate/README.md) for full configuration documentation.

### Lambda Functions (AWS Connect Integration)

See [lambda/README.md](lambda/README.md) for headless authentication flow between AWS Connect and PingFederate.

### Token Exchange Details

See [TOKENEXCHANGE.md](TOKENEXCHANGE.md) for complete OAuth2 token exchange implementation examples.

## Resources

- [PingFederate Docs](https://docs.pingidentity.com/pingfederate/)
- [Ping DevOps Helm Charts](https://helm.pingidentity.com/)
- [RFC 8693 - Token Exchange](https://datatracker.ietf.org/doc/html/rfc8693)


## Build Custom Image

1. Download the integration kit to the `docker` folder.
2. issue the following command to build

    ```console
    docker build . -t darkedges/pingfederate:edge
    docker push darkedges/pingfederate:edge  
    ```

## Terraform

```console
docker compose run --rm terraform-init init 
docker compose run --rm terraform-init plan 
docker compose run --rm terraform-init apply --auto-approve 
```

## Ping Federate Console

connect to <https://pfconsole.ping.darkedges.com/>

| username        | password        |
| --------------- | --------------- |
| `administrator` | `2FederateM0re` |

## Ping Data Console

connect to <https://pdconsole.ping.darkedges.com/>

| server                                    | username        | password        |
| ----------------------------------------- | --------------- | --------------- |
| `pingfederate-pingdirectory-cluster:1636` | `administrator` | `2FederateM0re` |
