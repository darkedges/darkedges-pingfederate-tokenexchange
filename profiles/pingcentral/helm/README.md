# Ping Central

<https://central.ping.darkedges.com>

| Username        | Password         |
| --------------- | ---------------- |
| `Administrator` | `2FederateM0re!` |

## docker

```console
docker run -it --rm --name pingcentral  --env-file devopsconfig --env PING_IDENTITY_ACCEPT_EULA=YES  --env PING_IDENTITY_DEVOPS_USER \--env PING_IDENTITY_DEVOPS_KEY  --tmpfs /run/secrets --publish 9022:9022 pingidentity/pingcentral:edge
```

## Helm

```console
helm upgrade --install pingcentral pingidentity/ping-devops --create-namespace --namespace pingfed -f pingcentral.yaml -f .\ingress.yaml
```
