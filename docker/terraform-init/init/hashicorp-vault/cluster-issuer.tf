resource "kubernetes_secret_v1" "certmanager" {
  metadata {
    name      = "cert-manager"
    namespace = "cert-manager"
    annotations = {
      "kubernetes.io/service-account.name" = "cert-manager"
    }
  }

  type       = "kubernetes.io/service-account-token"
  depends_on = [vault_kubernetes_auth_backend_role.certmanager]
}

resource "k8s_cert_manager_io_cluster_issuer_v1" "clusterissuer" {
  metadata = {
    name      = "vault-issuer"
    namespace = "cert-manager"
  }
  spec = {
    vault = {
      path   = "darkedges_idam_intermediate/sign/cert-manager"
      server = "http://vault.hashicorp-vault:8200"
      auth = {
        kubernetes = {
          role      = "cert-manager"
          mountPath = "/v1/auth/kubernetes"
          secret_ref = {
            name = kubernetes_secret_v1.certmanager.metadata[0].name
            key  = "token"
          }
        }
      }
    }
  }
  depends_on = [kubernetes_secret_v1.certmanager]
}

# use the 'yaml' attribute as input for the kubectl provider
resource "kubectl_manifest" "clusterissuer" {
  yaml_body = k8s_cert_manager_io_cluster_issuer_v1.clusterissuer.yaml
}

resource "k8s_cert_manager_io_cluster_issuer_v1" "siclusterissuer" {
  metadata = {
    name      = "ca-issuer"
    namespace = "cert-manager"
  }
  spec = {
    vault = {
      path   = "darkedges_idam_intermediate/root/sign-intermediate"
      server = "http://vault.hashicorp-vault:8200"
      auth = {
        kubernetes = {
          role      = "cert-manager"
          mountPath = "/v1/auth/kubernetes"
          secret_ref = {
            name = kubernetes_secret_v1.certmanager.metadata[0].name
            key  = "token"
          }
        }
      }
    }
  }
  depends_on = [kubernetes_secret_v1.certmanager]
}

# use the 'yaml' attribute as input for the kubectl provider
resource "kubectl_manifest" "siclusterissuer" {
  yaml_body = k8s_cert_manager_io_cluster_issuer_v1.siclusterissuer.yaml
}