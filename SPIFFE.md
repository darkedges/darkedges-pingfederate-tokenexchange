# SPIFFE 

```console
vault read auth/approle/role/chatbot/role-id
```

returns

```console
Key        Value
---        -----
role_id    ff5212b9-6f64-4f3f-a973-e5df4c29b1fe
```

```console
vault write -f auth/approle/role/chatbot/secret-id
```

returns

```console
Key                   Value
---                   -----
secret_id             1a87cb7d-aae8-3288-4037-9934dd0ab751
secret_id_accessor    fbbb453e-e7f6-f4c2-2525-5dfac3253f6c
secret_id_num_uses    0
secret_id_ttl         24h
```

```console
vault write -field=token auth/approle/login role_id="ff5212b9-6f64-4f3f-a973-e5df4c29b1fe" secret_id="1a87cb7d-aae8-3288-4037-9934dd0ab751"
```

returns

```console
xxx.xxxxxx
```

```console
vault login
Token (will be hidden): 
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.
```

returns

```console
Key                     Value
---                     -----
token                   xxx.xxxxxx
token_accessor          28L92orI5A16s2Y0pFvO6pPU
token_duration          59m48s
token_renewable         true
token_policies          ["default"]
identity_policies       ["application-identity-token-policies" "chatbot-production-secret-consumer"]
policies                ["default" "application-identity-token-policies" "chatbot-production-secret-consumer"]
token_meta_role_name    chatbot
```

```console
vault read -field=token identity/oidc/token/application_identity
```

returns

```console
eyJhbGciOiJSUzI1NiIsImtpZCI6IjY3NDJlZGM4LTYzMjUtMWE5Yi02OGUzLWQ5OTQ0MzkwZGQzMyJ9.eyJhcHBpbmZvIjp7ImJ1c2luZXNzX3VuaXQiOiJlbmdpbmVlcmluZyIsImVudmlyb25tZW50IjoicHJvZHVjdGlvbiJ9LCJhdWQiOiJzcGlmZmU6Ly92YXVsdC5sb2NhbGRldi5kYXJrZWRnZXMuY29tL2FwcGxpY2F0aW9uIiwiYXpwIjoic3BpZmZlOi8vdmF1bHQvYXBwbGljYXRpb24vcHJvZHVjdGlvbi9lbmdpbmVlcmluZy9DaGF0Qm90IiwiZXhwIjoxNzY5NDgwMzM5LCJncm91cHMiOlsiQ2hhdEJvdCBncm91cCJdLCJpYXQiOjE3NjkzOTM5MzksImlzcyI6Imh0dHBzOi8vdmF1bHQubG9jYWxkZXYuZGFya2VkZ2VzLmNvbS92MS9pZGVudGl0eS9vaWRjIiwibmFtZXNwYWNlIjoicm9vdCIsIm5iZiI6MTc2OTM5MzkzOSwic3ViIjoiZDBkNmYwNDgtNjcxMC05MzkzLWZiYTMtNTNiYjRlNjY4NDA5In0.xJVoHMQ6j1psUOeFnz6hiF_0F8yyLHgnPni85YStCps8E5eIapS7APH3LuET9_5AbBEDQwE_x0CjqF30QzzXPy9PM1u2xvNnZ5RIKNamOHGQo1PXpue9u6L-9iPb6_XP4kO3F49dFbCdUiK7BR7KrGND1GY_Ju31HWGX37TXGbzBg6pxhCzFUMWz-3Yyy4CC2gCY3G0JUPBWzecPY1gjXvjaFuGFD_Zi64nOmWwbe0fU4i5poiypwzH_96GZNGlBvJVEMT7dyOVo_q3Pv-Ha65zcMlC9moUc5lSXcK6RzFPiKSHxjdOdJmgUKGprVoE2bfAa8yB0VRpBJWIXUb2okg
```

decoded

```json
{
  "appinfo": {
    "business_unit": "engineering",
    "environment": "production"
  },
  "aud": "spiffe://vault.localdev.darkedges.com/application",
  "azp": "spiffe://vault/application/production/engineering/ChatBot",
  "exp": 1769480339,
  "groups": [
    "ChatBot group"
  ],
  "iat": 1769393939,
  "iss": "https://vault.localdev.darkedges.com/v1/identity/oidc",
  "namespace": "root",
  "nbf": 1769393939,
  "sub": "d0d6f048-6710-9393-fba3-53bb4e668409"
}
```
