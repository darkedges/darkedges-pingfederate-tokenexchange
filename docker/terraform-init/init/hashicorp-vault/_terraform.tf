terraform {
  required_version = "~> 1.14.3"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 5.6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.6.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19.0"
    }
    k8s = {
      source  = "metio/k8s"
      version = "2023.9.4"
    }
  }
  backend "local" { path = "/mnt/terraform/state" }
}