resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "applications" {
  for_each       = local.application_identities_map
  backend        = vault_auth_backend.approle.path
  role_name      = each.key
  token_ttl      = 3600
  token_max_ttl  = 86400
  bind_secret_id = true
  secret_id_ttl  = 86400
}

# Configure AppRole role to use sole entity inheritance via generic endpoint
resource "vault_generic_endpoint" "approle_entity_inherit" {
  for_each             = local.application_identities_map
  depends_on           = [vault_approle_auth_backend_role.applications]
  path                 = "auth/approle/role/${each.key}"
  ignore_absent_fields = true
  data_json = jsonencode({
    entity_alias_sole_inherit = true
  })
}

# Bind AppRole roles to their corresponding identity entities
# Use role_id as the alias name since that's how the role is identified in API calls
resource "vault_identity_entity_alias" "approle_applications" {
  for_each       = local.application_identities_map
  name           = vault_approle_auth_backend_role.applications[each.key].role_id
  mount_accessor = vault_auth_backend.approle.accessor
  canonical_id   = vault_identity_entity.application[each.key].id
}