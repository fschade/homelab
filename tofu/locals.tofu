locals {
  CONST = {
    NODE_NAME = {
      PVE_THINKCENTRE_01 = "pve-thinkcentre-01"
      PVE_THINKCENTRE_02 = "pve-thinkcentre-02"
      PVE_ZIMABLADE_01   = "pve-zimablade-01"
    }
  }

  defaults = {
    talos = {
      nodes = {
        shared = {
          server = {
            kubernetes = {
              version = "1.35.0"
            }
            talos = {
              version   = "1.12.5"
              iso       = "https://factory.talos.dev/image/b0f2a8b575460a3dcb1234cc081c73c88e795aaef36eda9b88a6f4dddbd49365/v1.12.5/nocloud-amd64.iso"
              installer = "factory.talos.dev/nocloud-installer/b0f2a8b575460a3dcb1234cc081c73c88e795aaef36eda9b88a6f4dddbd49365:v1.12.5"

              //version   = "1.12.6"
              //iso       = "https://factory.talos.dev/image/b0f2a8b575460a3dcb1234cc081c73c88e795aaef36eda9b88a6f4dddbd49365/v1.12.6/nocloud-amd64.iso"
              //installer = "factory.talos.dev/nocloud-installer/b0f2a8b575460a3dcb1234cc081c73c88e795aaef36eda9b88a6f4dddbd49365:v1.12.6"
            }
          }
        }
        (module.talos.CONST.MACHINE_TYPE.CONTROL_PLANE) = {
          vm = {
            cpu = {
              cores = 4
            }
            memory = {
              dedicated = 4 * 1024
            }
          }
        }
        (module.talos.CONST.MACHINE_TYPE.WORKER) = {
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
  }
}