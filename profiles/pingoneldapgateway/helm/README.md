# PingOne LDAP Gateway Helm Chart

Helm chart for deploying PingOne LDAP Gateway on Kubernetes.

## Overview

This Helm chart provides a basic deployment of the PingOne LDAP Gateway, which allows LDAP clients to connect to PingOne Identity Cloud for authentication and directory services.

## Installation

### Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- kubectl configured to access your cluster

### Add Helm Repository

```bash
helm repo add pingidentity https://helm.pingidentity.com/
helm repo update
```

### Install the Chart

```bash
# Install with default values
helm install pingone-ldap-gateway ./helm \
  --namespace ldapgateway \
  --create-namespace

# Install with custom values
helm install pingone-ldap-gateway ./helm \
  --namespace ldapgateway \
  --create-namespace \
  -f values.yaml
```

### Upgrade an Existing Release

```bash
helm upgrade pingone-ldap-gateway ./helm \
  --namespace ldapgateway \
  -f values.yaml
```

### Uninstall the Chart

```bash
helm uninstall pingone-ldap-gateway \
  --namespace ldapgateway
```

## Configuration

### Basic Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `pingoneLdapGateway.enabled` | Enable PingOne LDAP Gateway deployment | `true` |
| `pingoneLdapGateway.replicaCount` | Number of replicas | `1` |
| `pingoneLdapGateway.image.repository` | Image repository | `pingidentity/pingone-ldap-gateway` |
| `pingoneLdapGateway.image.tag` | Image tag | `latest` |
| `pingoneLdapGateway.image.pullPolicy` | Image pull policy | `IfNotPresent` |

### Service Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `pingoneLdapGateway.service.type` | Service type | `ClusterIP` |
| `pingoneLdapGateway.service.ports.ldap.port` | LDAP port | `389` |
| `pingoneLdapGateway.service.ports.ldaps.port` | LDAPS (SSL/TLS) port | `636` |

### Resource Management

```yaml
pingoneLdapGateway:
  resources:
    requests:
      memory: "512Mi"
      cpu: "250m"
    limits:
      memory: "1Gi"
      cpu: "500m"
```

### Environment Variables

Configure environment variables in `values.yaml`:

```yaml
pingoneLdapGateway:
  env:
    - name: PING_IDENTITY_PASSWORD
      value: "your-password"
    - name: PING_DEBUG
      value: "false"
```

### Health Checks

Configure liveness and readiness probes:

```yaml
pingoneLdapGateway:
  livenessProbe:
    enabled: true
    initialDelaySeconds: 60
    periodSeconds: 10
  readinessProbe:
    enabled: true
    initialDelaySeconds: 30
    periodSeconds: 10
```

## Advanced Usage

### Using LoadBalancer Service

To expose LDAP externally via a load balancer:

```yaml
pingoneLdapGateway:
  service:
    type: LoadBalancer
```

### Custom Configuration

Mount custom configuration from ConfigMaps or Secrets:

```yaml
pingoneLdapGateway:
  volumeMounts:
    - name: config
      mountPath: /opt/config
  
  volumes:
    - name: config
      configMap:
        name: ldap-gateway-config
```

### Node Affinity

Schedule pods on specific nodes:

```yaml
nodeSelector:
  disktype: ssd

affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - node1
```

### Pod Security Policy

```yaml
podSecurityPolicy:
  enabled: true
```

## Monitoring

### Service Discovery

The service is automatically available within the cluster:

- **LDAP**: `pingone-ldap-gateway.ldapgateway.svc.cluster.local:389`
- **LDAPS**: `pingone-ldap-gateway.ldapgateway.svc.cluster.local:636`

### Viewing Logs

```bash
# Get pod name
kubectl get pods -n ldapgateway

# View logs
kubectl logs -n ldapgateway pingone-ldap-gateway-xxxxx -f
```

### Health Status

```bash
# Check deployment status
kubectl get deployment -n ldapgateway

# Check service endpoints
kubectl get endpoints -n ldapgateway

# Describe pod for events
kubectl describe pod -n ldapgateway <pod-name>
```

## Troubleshooting

### Connection Issues

Test LDAP connectivity:

```bash
# Port forward to local machine
kubectl port-forward -n ldapgateway service/pingone-ldap-gateway 389:389

# Test connection (requires ldapsearch or similar tool)
ldapsearch -h localhost -p 389 -x -b "dc=example,dc=com" "(uid=*)"
```

### Port Already in Use

If port 389/636 is already in use:

```yaml
pingoneLdapGateway:
  service:
    ports:
      ldap:
        port: 3389    # Use alternative port
```

### Debug Logging

Enable debug logging:

```yaml
pingoneLdapGateway:
  env:
    - name: PING_DEBUG
      value: "true"
    - name: VERBOSE
      value: "true"
```

## Common Examples

### Development Setup (Single Pod)

```bash
helm install pingone-ldap-gateway ./helm \
  --namespace ldapgateway \
  --create-namespace \
  --set pingoneLdapGateway.replicaCount=1 \
  --set pingoneLdapGateway.image.tag=latest
```

### Production Setup (Multiple Replicas)

```bash
helm install pingone-ldap-gateway ./helm \
  --namespace ldapgateway \
  --create-namespace \
  --set pingoneLdapGateway.replicaCount=3 \
  --set pingoneLdapGateway.service.type=LoadBalancer \
  --set pingoneLdapGateway.resources.limits.memory=2Gi
```

### With Custom Configuration

Create a `custom-values.yaml`:

```yaml
pingoneLdapGateway:
  image:
    tag: "1.2.0"
  replicaCount: 2
  service:
    type: LoadBalancer
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
    limits:
      memory: "2Gi"
      cpu: "1000m"
```

Then install:

```bash
helm install pingone-ldap-gateway ./helm \
  --namespace ldapgateway \
  --create-namespace \
  -f custom-values.yaml
```

## Related Documentation

- [PingOne Helm Charts](https://helm.pingidentity.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)

## License

ISC
