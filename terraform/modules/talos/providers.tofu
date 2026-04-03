terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.99.0"
    }

    talos = {
      source  = "siderolabs/talos"
      version = "0.10.1"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.13.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }

    deepmerge = {
      source  = "isometry/deepmerge"
      version = "~> 1.0"
    }
  }
}

provider "kubernetes" {
  host                   = local.kubernetes_config.host
  client_certificate     = local.kubernetes_config.client_certificate
  client_key             = local.kubernetes_config.client_key
  cluster_ca_certificate = local.kubernetes_config.cluster_ca_certificate
}

provider "helm" {
  kubernetes = local.kubernetes_config
}