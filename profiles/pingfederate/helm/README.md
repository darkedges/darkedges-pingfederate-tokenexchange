# Ping

## Deploy pingctl

```console
curl -sL https://bit.ly/pingctl-install | sh
sudo mv /home/nirving/pingctl /usr/local/bin/.
pingctl k8s generate devops-secret > devops.yaml
```

## Add PIng DevOps

```helm
helm repo add pingidentity https://helm.pingidentity.com/ 
helm repo update
```

## Deploy Ping Authorize

```console
kubectl apply -f devops.yaml
helm upgrade --install pingauthorize pingidentity/ping-devops --create-namespace --namespace ping -f pingauthorize-pingdirectory.yaml -f ingress.yaml
```

## Deploy Ping Federate

```console
kubectl apply -f devops.yaml
helm upgrade --install pingfederate pingidentity/ping-devops --create-namespace --namespace pingfed -f pingfederate.yaml -f ingress.yaml
```

## Console

### Directory

<https://pingdataconsole.pingauthorize.internal.darkedges.com.au>

| Server                        | Username        | Password        |
| ----------------------------- | --------------- | --------------- |
| `pingauthorize-pingdirectory` | `administrator` | `2FederateM0re` |

### Ping Authorize - Administration

<https://pingdataconsole.pingauthorize.internal.darkedges.com.au>

| Server                                     | Username        | Password        |
| ------------------------------------------ | --------------- | --------------- |
| `pingauthorize-pingauthorize-cluster:1636` | `administrator` | `2FederateM0re` |

### Ping Authorize - Policy Editor

<https://pingauthorizepap.pingauthorize.internal.darkedges.com.au/login>

| username | password      |
| -------- | ------------- |
| `admin`  | `password123` |

### Config

```console
mkdir /tmp/deployment
dsconfig create-deployment-package-store \
    --store-name FileStore  \
    --type filesystem  \
    --set poll-directory:/tmp/deployment 
dsconfig create-external-server \
    --server-name CIAM  \
    --type api  \
    --set base-url:https://fram.connectid.darkedges.com 
dsconfig create-access-token-validator \
    --validator-name CIAM  \
    --type jwt  \
    --set enabled:true  \
    --set authorization-server:CIAM  \
    --set jwks-endpoint-path:https://fram.connectid.darkedges.com/openam/oauth2/connect/jwk_uri 
dsconfig create-external-server \
    --server-name ProviderAPI  \
    --type api  \
    --set base-url:http://providerapi.kong:8080 
dsconfig create-gateway-api-endpoint \
    --endpoint-name ProviderAPI  \
    --set inbound-base-path:/providerapi  \
    --set outbound-base-path:/  \
    --set api-server:ProviderAPI 
```

### Kong gateway

```console
dsconfig create-sideband-api-shared-secret \
    --secret-name KongGateway  \
    --set shared-secret:AABolYuYjHiGbH5pGwVuEDNPKdA62eUiqJQ= 
dsconfig create-sideband-api-endpoint \
    --endpoint-name ProviderAPI  \
    --set service:ProviderAPI  \
    --set resource-path:/provider  \
    --set base-path:/provider 
dsconfig set-http-servlet-extension-prop \
    --extension-name "Sideband API"  \
    --set request-context-method:request 
```
