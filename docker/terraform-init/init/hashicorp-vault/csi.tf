resource "vault_mount" "secret" {
  path        = "secret"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_backend_v2" "secret" {
  mount                = vault_mount.secret.path
  max_versions         = 5
  delete_version_after = 12600
  cas_required         = false
}

resource "vault_kv_secret_v2" "secret" {
  mount                      = vault_mount.secret.path
  name                       = "db-pass"
  delete_all_versions        = true
  data_json                  = jsonencode(
  {
    password       = "db-secret-password"
  }
  )
}
resource "vault_policy" "secret" {
  name = "secret "

  policy = <<EOT
path "secret/data/db-pass" {
  capabilities = ["read"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "secret" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "secret"
  bound_service_account_names      = [  
    "webapp-sa"
  ]
  bound_service_account_namespaces = [
    "sandbox"
  ]
  token_ttl                        = 3600
  token_policies                   = [
    vault_policy.secret.name
    ]
}