# Token Exchange

See <https://docs.pingidentity.com/pingfederate/12.3/administrators_reference_guide/pf_config_oauth_token_exchange.html> for details 

## Defining token exchange processor policies

See <https://docs.pingidentity.com/pingfederate/12.3/administrators_reference_guide/pf_defining_token_exchange_processor_policies.html>

### Flow

```text
New Access Token Manager
    Applications -> OAuth -> Access Token Management

New Token processor
    Authentication -> Token Exchange -> Token Processor

New Processor Policy
```

## Enabling token exchange in OAuth clients

See <https://docs.pingidentity.com/pingfederate/12.3/administrators_reference_guide/pf_enabl_token_exchang_oauth_client.html>

### Flow

```text
New OAuth Client
    Applications -> OAuth -> Clients
```
