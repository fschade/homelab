module "talos" {
  source = "./modules/talos"

  providers = {
    proxmox = proxmox
  }

  cluster = {
    name              = "talos-cluster"
    gateway           = "10.42.10.1"
    virtual_shared_ip = "10.42.10.80"
    health_check = {
      enabled = false
    }
  }

  nodes = {
    for id, node in {
      control-plane-1 = {
        name = "control-plane-1"
        ip   = "10.42.10.81"
        type = module.talos.CONST.MACHINE_TYPE.CONTROL_PLANE
        vm = {
          datacenter = {
            node = local.CONST.NODE_NAME.PVE_THINKCENTRE_01
          }
        }
      },
      control-plane-2 = {
        name = "control-plane-2"
        ip   = "10.42.10.82"
        type = module.talos.CONST.MACHINE_TYPE.CONTROL_PLANE
        vm = {
          datacenter = {
            node = local.CONST.NODE_NAME.PVE_THINKCENTRE_01
          }
        }
      },
      control-plane-3 = {
        name = "control-plane-3"
        ip   = "10.42.10.83"
        type = module.talos.CONST.MACHINE_TYPE.CONTROL_PLANE
        vm = {
          datacenter = {
            node = local.CONST.NODE_NAME.PVE_THINKCENTRE_02
          }
        }
      },
      worker-1 = {
        name = "worker-1"
        ip   = "10.42.10.85"
        type = module.talos.CONST.MACHINE_TYPE.WORKER
        vm = {
          datacenter = {
            node = local.CONST.NODE_NAME.PVE_THINKCENTRE_01
          }
        }
      },
      worker-2 = {
        name = "worker-2"
        ip   = "10.42.10.86"
        type = module.talos.CONST.MACHINE_TYPE.WORKER
        vm = {
          datacenter = {
            node = local.CONST.NODE_NAME.PVE_THINKCENTRE_01
          }
        }
      },
      worker-3 = {
        name = "worker-3"
        ip   = "10.42.10.87"
        type = module.talos.CONST.MACHINE_TYPE.WORKER
        vm = {
          datacenter = {
            node = local.CONST.NODE_NAME.PVE_THINKCENTRE_01
          }
        }
      },
      worker-4 = {
        name = "worker-4"
        ip   = "10.42.10.88"
        type = module.talos.CONST.MACHINE_TYPE.WORKER
        vm = {
          datacenter = {
            node = local.CONST.NODE_NAME.PVE_THINKCENTRE_01
          }
        }
      },
      worker-5 = {
        name = "worker-5"
        ip   = "10.42.10.89"
        type = module.talos.CONST.MACHINE_TYPE.WORKER
        vm = {
          datacenter = {
            node = local.CONST.NODE_NAME.PVE_THINKCENTRE_02
          }
        }
      },
      worker-6 = {
        name = "worker-6"
        ip   = "10.42.10.90"
        type = module.talos.CONST.MACHINE_TYPE.WORKER
        vm = {
          datacenter = {
            node = local.CONST.NODE_NAME.PVE_THINKCENTRE_02
          }
        }
      }
    } : id => provider::deepmerge::mergo(
      local.defaults.talos.nodes.shared,
      local.defaults.talos.nodes[node.type],
      node,
      "no_null_override",
    )
  }
}