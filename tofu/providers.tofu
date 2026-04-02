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
  endpoint = "https://10.42.10.6:8006/"
  username = var.proxmox_username
  password = var.proxmox_password
  insecure = true

  ssh {
    agent = true

    dynamic "node" {
      for_each = {
        (local.CONST.NODE_NAME.PVE_THINKCENTRE_01) = "10.42.10.6"
        (local.CONST.NODE_NAME.PVE_THINKCENTRE_02) = "10.42.10.7"
        (local.CONST.NODE_NAME.PVE_ZIMABLADE_01) = "10.42.10.8"
      }

      content {
        name    = node.key
        address = node.value
      }
    }
  }
}
