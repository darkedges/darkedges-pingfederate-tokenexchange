provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.config_context
}

provider "kubectl" {
  config_path    = "~/.kube/config"
  config_context = "docker-desktop"
}

provider "vault" {
  address = "http://host.docker.internal:${local.nodeport}"
}