resource "vault_mount" "pki_spiffe_intermediate" {
  path                      = "spiffe_intermediate"
  type                      = "pki"
  description               = "This is an pki_spiffe_intermediate mount"
  default_lease_ttl_seconds = 86400
  max_lease_ttl_seconds     = 157680000
}

resource "vault_pki_secret_backend_intermediate_cert_request" "spiffe" {
  depends_on            = [vault_mount.pki_intermediate]
  backend               = vault_mount.pki_spiffe_intermediate.path
  type                  = "internal"
  common_name           = "Spiffe Intermediate"
  add_basic_constraints = true
}

resource "vault_pki_secret_backend_root_sign_intermediate" "spiffe" {
  depends_on           = [vault_pki_secret_backend_intermediate_cert_request.spiffe]
  backend              = vault_mount.pki_root.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.spiffe.csr
  common_name          = "SPIFFE Intermediate"
  format               = "pem_bundle"
  exclude_cn_from_sans = true
  ou                   = var.ou
  organization         = var.organisation
  issuer_ref           = vault_pki_secret_backend_root_cert.root.issuer_id
}

resource "vault_pki_secret_backend_intermediate_set_signed" "spiffe" {
  backend     = vault_mount.pki_spiffe_intermediate.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.spiffe.certificate
}

resource "vault_pki_secret_backend_config_urls" "spiffe_intermediate_config_urls" {
  backend                 = vault_mount.pki_spiffe_intermediate.path
  crl_distribution_points = ["${var.vault_url}/v1/${vault_mount.pki_spiffe_intermediate.path}/crl"]
  issuing_certificates    = ["${var.vault_url}/v1/${vault_mount.pki_spiffe_intermediate.path}/ca"]
}

resource "vault_pki_secret_backend_issuer" "spiffe" {
  backend     = vault_mount.pki_spiffe_intermediate.path
  issuer_ref  = vault_pki_secret_backend_intermediate_set_signed.spiffe.imported_issuers[0]
  issuer_name = "spiffe-intermediate"
}

resource "vault_pki_secret_backend_role" "spiffe" {
  backend             = vault_mount.pki_spiffe_intermediate.path
  issuer_ref          = vault_pki_secret_backend_issuer.spiffe.issuer_ref
  name                = "spiffe"
  allow_any_name      = true
  allow_glob_domains  = true
  allow_subdomains    = true
  allowed_domains     = var.allowed_domains
  require_cn          = false
  use_csr_common_name = true
  use_csr_sans        = true
}

resource "vault_policy" "spiffe" {
  name = "spiffe"

  policy = <<EOT
 path "${vault_mount.pki_spiffe_intermediate.path}/issue/machine-id" {
   capabilities = ["read", "update","list"]
 }

# Allow generating OIDC/JWT tokens for the SPIFFE identity
path "identity/oidc/token/application_identity" {
  capabilities = ["read"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "spiffe" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "spiffe"
  bound_service_account_names      = [  
    "webapp-sa"
  ]
  bound_service_account_namespaces = [
    "sandbox"
  ]
  token_ttl                        = 3600
  token_policies                   = [
    vault_policy.spiffe.name
    ]
}