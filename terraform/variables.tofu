variable "proxmox_username" {
  description = "Username for the Proxmox provider (e.g. root@pam or terraform@pve)"
  type        = string
  sensitive   = true
}

variable "proxmox_password" {
  description = "Password for the Proxmox provider"
  type        = string
  sensitive   = true
}

variable "proxmox" {
  type = object({
    endpoint = string
    insecure = bool
    ssh = object({
      agent = bool
      nodes = map(string)
    })
  })
}

variable "talos_cluster" {
  type = object({
    name    = string
    virtual_shared_ip = optional(string)
    gateway = string
    subnet_mask = optional(number)
    health_check = optional(object({
      enabled = optional(bool)
      skip_kubernetes_checks = optional(bool)
      timeouts = optional(object({
        read = optional(string)
      }))
    }))
  })
}

variable "talos_nodes" {
  type = map(object({
    type = string
    name = string
    server = optional(object({
      kubernetes = object({
        version = string
      })
      talos = object({
        version   = string
        iso       = string
        installer = string
      })
    }))
    vm = object({
      id = optional(number)
      ip = string
      mac_address = optional(string)
      network_interface = optional(string)
      datacenter = object({
        node = string
      })
      labels = optional(list(string))
      cpu = optional(object({
        sockets = optional(number)
        cores = optional(number)
        type = optional(string)
      }))
      memory = optional(object({
        dedicated = optional(number)
      }))
      disk = optional(object({
        datastore_id = optional(string)
        size = optional(number)
      }))
      image = optional(object({
        datastore_id = optional(string)
      }))
      dns = optional(object({
        servers = optional(list(string))
      }))
    })
  }))
}