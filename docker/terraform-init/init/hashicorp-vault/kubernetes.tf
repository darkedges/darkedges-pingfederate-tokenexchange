resource "kubernetes_cluster_role_binding" "certmanager_token" {
  metadata {
    name = "cert-manager"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cert-manager"
    namespace = "cert-manager"
  }
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "certmanager" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = "https://kubernetes.default.svc.cluster.local"
  issuer                 = "api"
  disable_iss_validation = "true"
}

resource "vault_policy" "certmanager-policy" {
  name = "certmanager-policy"

  policy = <<EOT
path "${var.namespace}_idam_intermediate/*" {
  capabilities = ["read","list","delete","update","create"]
}
path "${var.namespace}_idam_root/*" {
  capabilities = ["read","list","delete","update","create"]
}
path "auth/token/renew" {
  capabilities = ["update"]
}
path "auth/token/renew-self" {
  capabilities = ["update"]
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "certmanager" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "cert-manager"
  bound_service_account_names      = var.bound_service_account_names
  bound_service_account_namespaces = var.bound_service_account_namespaces
  token_ttl                        = 3600
  token_policies                   = [vault_policy.certmanager-policy.name]
}
