# PingOne LDAP Gateway Server Profile

This directory contains the server profile and Helm deployment configuration for PingOne LDAP Gateway.

## Directory Structure

```
pingoneldapgateway/
├── helm/                    # Helm chart for Kubernetes deployment
│   ├── Chart.yaml          # Chart metadata
│   ├── values.yaml         # Default configuration values
│   ├── README.md           # Helm chart documentation
│   └── templates/          # Kubernetes resource templates
│       ├── deployment.yaml # Deployment configuration
│       └── _helpers.tpl    # Helm template helpers
└── README.md              # This file
```

## Quick Start

### Kubernetes Deployment

```bash
# Add Ping Helm repository
helm repo add pingidentity https://helm.pingidentity.com/
helm repo update

# Install PingOne LDAP Gateway
helm upgrade --install pingone-ldap-gateway ./helm \
  --namespace pingfed \
  --create-namespace \
  -f helm/values.yaml
```

### Verify Deployment

```bash
# Check pods
kubectl get pods -n ldapgateway

# Check service
kubectl get service -n ldapgateway

# View logs
kubectl logs -n ldapgateway -l app.kubernetes.io/name=pingone-ldap-gateway -f
```

## Configuration

### Default Credentials

Default configuration in `helm/values.yaml`:

- **Port (LDAP)**: 389
- **Port (LDAPS)**: 636
- **Password**: 2FederateM0re

### Customize Configuration

Edit `helm/values.yaml` to customize:

```yaml
pingoneLdapGateway:
  replicaCount: 1
  image:
    tag: latest
  service:
    type: ClusterIP
  env:
    - name: PING_IDENTITY_PASSWORD
      value: "your-secure-password"
```

### Environment Variables

Configure via `pingoneLdapGateway.env` in values.yaml:

| Variable                 | Description            | Default         |
| ------------------------ | ---------------------- | --------------- |
| `PING_IDENTITY_PASSWORD` | Admin password         | `2FederateM0re` |
| `PING_DEBUG`             | Enable debug logging   | `false`         |
| `VERBOSE`                | Enable verbose logging | `false`         |

## Networking

### Service Types

#### ClusterIP (Default)
Access only from within the cluster:
```bash
kubectl port-forward -n ldapgateway service/pingone-ldap-gateway 389:389
```

#### LoadBalancer
Expose externally (requires load balancer support):
```yaml
pingoneLdapGateway:
  service:
    type: LoadBalancer
```

### Port Mapping

| Service Port | Container Port | Protocol    |
| ------------ | -------------- | ----------- |
| 389          | 389            | TCP (LDAP)  |
| 636          | 636            | TCP (LDAPS) |

## Monitoring & Troubleshooting

### Health Checks

Liveness and readiness probes are configured to check TCP connectivity on port 389:

```yaml
livenessProbe:
  tcpSocket:
    port: ldap
  initialDelaySeconds: 60
  periodSeconds: 10

readinessProbe:
  tcpSocket:
    port: ldap
  initialDelaySeconds: 30
  periodSeconds: 10
```

### Viewing Logs

```bash
# Stream logs
kubectl logs -n ldapgateway -l app.kubernetes.io/name=pingone-ldap-gateway -f

# View specific pod
kubectl logs -n ldapgateway <pod-name>

# Previous logs
kubectl logs -n ldapgateway <pod-name> --previous
```

### Testing Connectivity

```bash
# Port forward to local machine
kubectl port-forward -n ldapgateway service/pingone-ldap-gateway 389:389

# Test with ldapsearch (if installed)
ldapsearch -h localhost -p 389 -x -b "dc=example,dc=com" "(objectClass=*)"

# Or use netcat to check port
nc -zv localhost 389
```

## Scaling

### Manual Scaling

```bash
# Scale to 3 replicas
kubectl scale deployment pingone-ldap-gateway -n ldapgateway --replicas=3

# Or update values
helm upgrade pingone-ldap-gateway ./helm \
  --namespace ldapgateway \
  --set pingoneLdapGateway.replicaCount=3
```

## Integration with PingFederate

PingOne LDAP Gateway can be used as a user directory source for PingFederate:

1. Deploy PingOne LDAP Gateway
2. Configure PingFederate to use LDAP connector pointing to the service:
   - **Server**: `pingone-ldap-gateway.ldapgateway.svc.cluster.local`
   - **Port**: `389`
3. Test the connection in PingFederate Admin Console

## Resource Management

### Default Resources

```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "250m"
  limits:
    memory: "1Gi"
    cpu: "500m"
```

### Custom Resources

Adjust based on your workload:

```yaml
pingoneLdapGateway:
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
    limits:
      memory: "2Gi"
      cpu: "1000m"
```

## Security

### Service Account

A dedicated service account is created:

```bash
kubectl get serviceaccount -n ldapgateway
```

### Security Context

Pods run as non-root user (UID 9031):

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 9031
  fsGroup: 0
```

### Network Policies

Optional network policies can be enabled:

```yaml
networkPolicy:
  enabled: true
```

## Uninstall

```bash
helm uninstall pingone-ldap-gateway \
  --namespace ldapgateway

# Remove namespace (optional)
kubectl delete namespace ldapgateway
```

## Documentation

- [Helm Chart Documentation](./helm/README.md)
- [Chart Values](./helm/values.yaml)
- [PingOne Documentation](https://docs.pingidentity.com/pingone)
- [Kubernetes Helm Docs](https://helm.sh/docs/)

## Support

For issues or questions:
1. Check logs: `kubectl logs -n ldapgateway -l app.kubernetes.io/name=pingone-ldap-gateway`
2. Review helm chart values: `helm get values pingone-ldap-gateway -n ldapgateway`
3. Verify pod status: `kubectl describe pod -n ldapgateway <pod-name>`
