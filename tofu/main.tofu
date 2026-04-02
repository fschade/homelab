module "talos" {
  source = "./modules/talos"

  providers = {
    proxmox = proxmox
  }

  cluster = var.talos_cluster
  nodes = local.talos_nodes
}