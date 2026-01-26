resource "vault_identity_oidc" "default" {
  issuer = var.vault_url
}

resource "vault_identity_oidc_key" "application_identity" {
  name             = "vault.localdev.darkedges.com"
  algorithm        = "RS256"
  rotation_period  = 86400
  verification_ttl = 86400
}

resource "vault_identity_oidc_role" "application_identity" {
  name      = "application_identity"
  key       = vault_identity_oidc_key.application_identity.name
  client_id = "spiffe://vault.localdev.darkedges.com/application"
  ttl       = 86400

  template = <<EOT
{
  "azp": {{identity.entity.metadata.spiffe_id}},
  "nbf": {{time.now}},
  "groups": {{identity.entity.groups.names}},
  "appinfo": {
    "business_unit": {{identity.entity.metadata.business_unit}},
    "environment": {{identity.entity.metadata.environment}}
  }
}
EOT
}

resource "vault_identity_oidc_key_allowed_client_id" "application_identity" {
  key_name          = vault_identity_oidc_key.application_identity.name
  allowed_client_id = vault_identity_oidc_role.application_identity.client_id
}

resource "vault_policy" "application-identity-token-policies" {
  name   = "application-identity-token-policies"
  policy = <<EOF
 path "identity/oidc/token/application_identity" {
   capabilities = ["read"]
 }
 EOF
}

resource "vault_policy" "application_identity" {
  name   = "application_identity"
  policy = <<EOF
 path "identity/oidc/token/application_identity" {
   capabilities = ["read"]
 }
 EOF
}

resource "vault_identity_oidc_key" "human_identity" {
  name      = "human_identity"
  algorithm = "RS256"
}

resource "vault_identity_oidc_role" "human_identity" {
  name      = "human_identity"
  template  = <<EOT
{
  "azp": {{identity.entity.metadata.spiffe_id}},
  "nbf": {{time.now}},
  "groups": {{identity.entity.groups.names}},
  "userinfo": {
    "name": {{identity.entity.name}},
    "email": {{identity.entity.metadata.email}},
    "role": {{identity.entity.metadata.role}},
    "team": {{identity.entity.metadata.team}}
    }
}
EOT
  client_id = "spiffe://vault.localdev.darkedges.com/human"
  key       = vault_identity_oidc_key.human_identity.name
  ttl       = 8 * 60 * 60 // 8 hours for human identity token
}

resource "vault_identity_oidc_key_allowed_client_id" "human_identity" {
  key_name          = vault_identity_oidc_key.human_identity.name
  allowed_client_id = vault_identity_oidc_role.human_identity.client_id
}

resource "vault_policy" "human-identity-token-policies" {
  name   = "human-identity-token-policies"
  policy = <<EOF
 path "identity/oidc/token/human_identity" {
   capabilities = ["read"]
 }
 EOF
}

resource "vault_identity_oidc_provider" "default" {
  name          = "default"
  https_enabled = true
  issuer_host   = "nginx:443"
  allowed_client_ids = [
    vault_identity_oidc_role.application_identity.client_id,
    vault_identity_oidc_role.human_identity.client_id
  ]
}