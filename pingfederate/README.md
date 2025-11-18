# PingFederate Configuration

This repository contains PingFederate server profiles and deployment configurations for token exchange and OAuth2/OIDC workflows.

## Overview

This folder provides a complete PingFederate setup with pre-configured server profiles, bulk configurations, and Helm deployment manifests for Kubernetes environments.

## Directory Structure

```text
pingfederate/
├── admin/                     # PingFederate Admin server profile
│   ├── env_vars               # Environment-specific variables
│   ├── motd                   # Message of the day
│   └── instance/              # Server instance configuration
│       ├── bulk-config/       # Bulk configuration data
│       │   └── data.json.subst
│       └── server/default/data/
│           └── pf.jwk         # JSON Web Key for signing/encryption
├── bulk-export/               # Configuration export/backup
│   └── shared/
│       ├── data.json          # Exported configuration
│       ├── data.json.subst    # Template with substitution variables
│       ├── env_vars           # Variable definitions
│       └── pf-config.json     # PingFederate configuration
└── helm/                      # Kubernetes Helm deployment files
    ├── ingress.yaml           # Ingress configuration
    ├── pingauthorize-pingdirectory.yaml
    ├── pingfederate.yaml      # Main deployment values
    └── README.md              # Deployment documentation
```

## Configuration Components

### Admin Server Profile

The `admin/` directory contains the server profile for the PingFederate administrative console:

- **env_vars**: Configures sensitive values including:
  - Data store credentials
  - SSL certificates and passwords
  - System encryption keys
  - Admin password (`PING_IDENTITY_PASSWORD`)

- **bulk-config/data.json.subst**: PingFederate configuration template (version 12.3.3.1) with variable substitution support for dynamic environments

- **server/default/data/pf.jwk**: JSON Web Key for OAuth2/OIDC token signing and encryption

### Bulk Export

The `bulk-export/shared/` directory contains exportable configurations:

- **data.json**: Complete PingFederate configuration export
- **data.json.subst**: Template version for environment-specific deployments
- **env_vars**: Variable placeholders for secure credential management

```bash
curl --location --request GET 'https:/admin.ping.darkedges.com/pf-admin-api/v1/bulk/export' --header 'X-XSRF-Header: PingFederate' --user "administrator:2FederateM0re" -k > bulk-export/shared/data.json
docker run --rm -v $PWD/bulk-export/shared:/shared darkedges/ping-bulkexport-tools:latest /shared/pf-config.json /shared/data.json /shared/env_vars /shared/data.json.subst > bulk-export/shared/convert.log
cp bulk-export/shared/data.json.subst admin/instance/bulk-config/
```

### Helm Deployment

See the [helm/README.md](helm/README.md) for detailed deployment instructions.

## Deployment

### Prerequisites

1. Install `pingctl`:

   ```bash
   curl -sL https://bit.ly/pingctl-install | sh
   sudo mv ~/pingctl /usr/local/bin/
   ```

2. Add Ping Identity Helm repository:

   ```bash
   helm repo add pingidentity https://helm.pingidentity.com/
   helm repo update
   ```

3. Generate DevOps secret:

   ```bash
   pingctl k8s generate devops-secret > devops.yaml
   ```

### Deploy to Kubernetes

1. Apply DevOps credentials:

   ```bash
   kubectl apply -f devops.yaml
   ```

2. Deploy PingFederate:

   ```bash
   helm upgrade --install pingfederate pingidentity/ping-devops \
     --create-namespace --namespace pingfed \
     -f helm/pingfederate.yaml \
     -f helm/ingress.yaml
   ```

## Configuration Details

### Server Profile Source

The admin server profile is pulled from this GitHub repository:

- **URL**: `https://github.com/darkedges/darkedges-pingfederate-tokenexchange.git`
- **Path**: `pingfederate/admin`

### Default Credentials

**⚠️ Security Warning**: Change these credentials in production environments!

- **Admin Password**: `2FederateM0re`
- **Keystore Password**: `2FederateM0re`

### Key Features

- OAuth2/OIDC token exchange support
- Pre-configured SSL certificates
- System encryption keys for secure data storage
- Bulk configuration for rapid deployment
- Environment variable substitution for multi-environment support

## Environment Variables

Key environment variables used in deployment:

- `SERVER_PROFILE_URL`: Git repository URL for server profile
- `SERVER_PROFILE_PATH`: Path within repository to profile
- `PING_IDENTITY_PASSWORD`: Admin console password
- `dataStores_items_ProvisionerDS_ProvisionerDS_password`: Data store credential
- `keyPairs_sslServer_*`: SSL certificate and key data
- `serverSettings_systemKeys_*`: Encryption keys for system security

## Version

This configuration is built for **PingFederate version 12.3.3.1**.

## Additional Resources

- [PingFederate Documentation](https://docs.pingidentity.com/pingfederate/)
- [Ping DevOps Helm Charts](https://helm.pingidentity.com/)
- [Token Exchange RFC 8693](https://datatracker.ietf.org/doc/html/rfc8693)

## Notes

- The `bulk-config` directory uses templated JSON files (`.subst` extension) for variable substitution
- Environment-specific values should be managed through `env_vars` files
- JWK files contain cryptographic keys and should be protected
- Configuration exports enable versioning and disaster recovery

