variable "cluster" {
  type = object({
    name    = string
    virtual_shared_ip = optional(string)
    network_interface = optional(string, "eth0")
    gateway = string
    subnet_mask = optional(number, 24)
    health_check = optional(object({
      enabled = optional(bool, true)
      skip_kubernetes_checks = optional(bool, false)
      timeouts = optional(object({
        read = optional(string, "30m")
      }), {})
    }), {})
  })
}

variable "nodes" {
  type = map(object({
    name = string
    ip   = string
    type = string
    server = object({
      kubernetes = object({
        version = string
      })
      talos = object({
        version   = string
        iso       = string
        installer = string
      })
    })
    vm = object({
      id = optional(number)
      datacenter = object({
        node = string
      })
      labels = optional(list(string), [])
      cpu = optional(object({
        sockets = optional(number)
        cores = optional(number)
        type = optional(string, "host")
      }), {})
      memory = optional(object({
        dedicated = optional(number)
      }), {})
      disk = optional(object({
        datastore_id = optional(string, "local-zfs")
        size = optional(number, 32)
      }), {})
      image = optional(object({
        datastore_id = optional(string, "local")
      }), {})
      dns = optional(object({
        servers = optional(list(string))
      }), {})
    })
  }))

  validation {
    condition = alltrue([
      for _, node in var.nodes :startswith(node.server.kubernetes.version, "v")
    ])
    error_message = "Kubernetes version must start with 'v', such as 'v1.28.0'"
  }

  validation {
    condition = alltrue([
      for _, node in var.nodes :startswith(node.server.talos.version, "v")
    ])
    error_message = "Talos version must start with 'v', such as 'v1.28.0'"
  }
}

