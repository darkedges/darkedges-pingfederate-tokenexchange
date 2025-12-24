data "kubernetes_service_v1" "vault" {
  metadata {
    name      = "vault-ui"
    namespace = "hashicorp-vault"
  }
}

locals {
  nodeport = [
    for port in data.kubernetes_service_v1.vault.spec[0].port :
    port.node_port if(port.port == 8200)
  ][0]
}

variable "config_context" {
  type    = string
  default = "docker-desktop"
}

variable "namespace" {
  type    = string
  default = "darkedges"
}

variable "bound_service_account_namespaces" {
  type    = list(string)
  default = ["cert-manager"]
}

variable "bound_service_account_names" {
  type    = list(string)
  default = ["cert-manager"]
}

variable "vaulturl" {
  type    = string
  default = "https://vault.localdev.darkedges.com"
}

variable "allowed_domains" {
  type    = list(string)
  default = ["darkedges"]
}

variable "organisation" {
  type    = string
  default = "darkedges"
}

variable "country" {
  type    = string
  default = "AU"
}

variable "locality" {
  type    = string
  default = "Melbourne"
}

variable "ou" {
  type    = string
  default = "IDAM"
}