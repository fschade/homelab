// talos
locals {
  talos_data = {
    nodes = {
      server = {
        talos_1_12_5 = {
          version   = "v1.12.5"
          iso       = "https://factory.talos.dev/image/b0f2a8b575460a3dcb1234cc081c73c88e795aaef36eda9b88a6f4dddbd49365/v1.12.5/nocloud-amd64.iso"
          installer = "factory.talos.dev/nocloud-installer/b0f2a8b575460a3dcb1234cc081c73c88e795aaef36eda9b88a6f4dddbd49365:v1.12.5"
        }
        talos_1_12_6 = {
          version   = "v1.12.6"
          iso       = "https://factory.talos.dev/image/b0f2a8b575460a3dcb1234cc081c73c88e795aaef36eda9b88a6f4dddbd49365/v1.12.6/nocloud-amd64.iso"
          installer = "factory.talos.dev/nocloud-installer/b0f2a8b575460a3dcb1234cc081c73c88e795aaef36eda9b88a6f4dddbd49365:v1.12.6"
        }
      }
    }
  }

  talos_defaults = {
    nodes = {
      shared = {
        server = {
          kubernetes = {
            version = "v1.35.0"
          }
          talos = local.talos_data.nodes.server.talos_1_12_5
        }
      }
      controlplane = {
        vm = {
          cpu = {
            cores = 4
          }
          memory = {
            dedicated = 4 * 1024
          }
        }
      }
      worker = {
        vm = {
          cpu = {
            cores = 8
          }
          memory = {
            dedicated = 8 * 1024
          }
        }
      }
    }
  }

  talos_nodes = {
    for id, node in var.talos_nodes : id => provider::deepmerge::mergo(
      local.talos_defaults.nodes.shared,
      local.talos_defaults.nodes[node.type],
      node,
      "no_null_override",
    )
  }
}