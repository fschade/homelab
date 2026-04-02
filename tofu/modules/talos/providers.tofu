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

    deepmerge = {
      source  = "isometry/deepmerge"
      version = "~> 1.0"
    }
  }
}