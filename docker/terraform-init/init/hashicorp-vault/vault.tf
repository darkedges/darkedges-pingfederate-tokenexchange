
resource "vault_mount" "pki_root" {
  path                      = "${var.namespace}_idam_root"
  type                      = "pki"
  description               = "This is an pki_root mount"
  default_lease_ttl_seconds = "315360000"
  max_lease_ttl_seconds     = "315360000"
}

resource "vault_pki_secret_backend_root_cert" "root" {
  depends_on           = [vault_mount.pki_root]
  backend              = vault_mount.pki_root.path
  type                 = "internal"
  issuer_name          = "idam-root"
  common_name          = "${var.organisation} ${var.ou} Root"
  ttl                  = "315360000"
  key_bits             = 4096
  exclude_cn_from_sans = true
  ou                   = var.ou
  organization         = var.organisation
  country              = var.country
  locality             = var.locality
}

resource "vault_pki_secret_backend_issuer" "root" {
  backend                        = vault_mount.pki_root.path
  issuer_ref                     = vault_pki_secret_backend_root_cert.root.issuer_id
  issuer_name                    = vault_pki_secret_backend_root_cert.root.issuer_name
  revocation_signature_algorithm = "SHA256WithRSA"
}

resource "vault_pki_secret_backend_role" "role" {
  backend          = vault_mount.pki_root.path
  name             = "admin-role"
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allow_subdomains = true
  allow_any_name   = true
}


resource "vault_pki_secret_backend_config_urls" "idam_root_config_urls" {
  backend                 = vault_mount.pki_root.path
  crl_distribution_points = ["${var.vaulturl}/v1/${vault_mount.pki_root.path}/crl"]
  issuing_certificates    = ["${var.vaulturl}/v1/${vault_mount.pki_root.path}/ca"]
}


resource "vault_mount" "pki_intermediate" {
  path                      = "${var.namespace}_idam_intermediate"
  type                      = "pki"
  description               = "This is an pki_intermediate mount"
  default_lease_ttl_seconds = 86400
  max_lease_ttl_seconds     = 157680000
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  depends_on            = [vault_mount.pki_intermediate]
  backend               = vault_mount.pki_intermediate.path
  type                  = "internal"
  common_name           = "${var.organisation} Intermediate"
  add_basic_constraints = true
}

resource "vault_pki_secret_backend_root_sign_intermediate" "intermediate" {
  depends_on           = [vault_pki_secret_backend_intermediate_cert_request.intermediate]
  backend              = vault_mount.pki_root.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  common_name          = "${var.organisation} ${var.ou} Intermediate"
  format               = "pem_bundle"
  exclude_cn_from_sans = true
  ou                   = var.ou
  organization         = var.organisation
  issuer_ref           = vault_pki_secret_backend_root_cert.root.issuer_id
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend     = vault_mount.pki_intermediate.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.intermediate.certificate
}

resource "vault_pki_secret_backend_config_urls" "idam_intermediate_config_urls" {
  backend                 = vault_mount.pki_intermediate.path
  crl_distribution_points = ["${var.vaulturl}/v1/${vault_mount.pki_intermediate.path}/crl"]
  issuing_certificates    = ["${var.vaulturl}/v1/${vault_mount.pki_intermediate.path}/ca"]
}

resource "vault_pki_secret_backend_issuer" "intermediate" {
  backend     = vault_mount.pki_intermediate.path
  issuer_ref  = vault_pki_secret_backend_intermediate_set_signed.intermediate.imported_issuers[0]
  issuer_name = "idam-intermediate"
}

resource "vault_pki_secret_backend_role" "backend_role_idam" {
  backend             = vault_mount.pki_intermediate.path
  issuer_ref          = vault_pki_secret_backend_issuer.intermediate.issuer_ref
  name                = "cert-manager"
  allow_any_name      = true
  allow_glob_domains  = true
  allow_subdomains    = true
  allowed_domains     = var.allowed_domains
  require_cn          = false
  use_csr_common_name = true
  use_csr_sans        = true
}