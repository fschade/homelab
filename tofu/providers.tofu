terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.99.0"
    }

    deepmerge = {
      source  = "isometry/deepmerge"
      version = "1.2.1"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox.endpoint
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = var.proxmox.insecure

  ssh {
    agent = var.proxmox.ssh.agent

    dynamic "node" {
      for_each = var.proxmox.ssh.nodes

      content {
        name    = node.key
        address = node.value
      }
    }
  }
}
