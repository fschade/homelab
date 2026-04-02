resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "this" {
  for_each = var.nodes

  talos_version      = each.value.server.talos.version
  kubernetes_version = each.value.server.kubernetes.version

  cluster_name     = var.cluster.name
  machine_type     = each.value.type
  cluster_endpoint = local.custer_endpoint
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  config_patches = compact(concat(
    // global patches
    [
      templatefile("${path.module}/templates/talos-machine-configuration-global-common.yaml.tftpl", {
        install_image = each.value.server.talos.installer
      })
    ],
    {
      // CONTROL_PLANE patches
      (local.CONST.MACHINE_TYPE.CONTROL_PLANE) : [
        templatefile("${path.module}/templates/talos-machine-configuration-global-controlplane.yaml.tftpl", {}),
      ]
      // WORKER patches
      (local.CONST.MACHINE_TYPE.WORKER) : [
        templatefile("${path.module}/templates/talos-machine-configuration-global-worker.yaml.tftpl", {}),
      ]
    }[
    each.value.type
    ]
  ))
}

resource "talos_machine_configuration_apply" "this" {
  for_each = var.nodes

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[each.key].machine_configuration
  node                        = each.value.ip
  apply_mode                  = "auto"

  config_patches = compact(concat(
    // global patches
    [
      templatefile("${path.module}/templates/talos-machine-configuration-node-common.yaml.tftpl", {
        network_interface = var.cluster.network_interface
        ip                = each.value.ip
        subnet_mask       = var.cluster.subnet_mask
        gateway           = var.cluster.gateway
        hostname          = each.value.name
      })
    ],
    {
      // CONTROL_PLANE patches
      (local.CONST.MACHINE_TYPE.CONTROL_PLANE) : [
        templatefile("${path.module}/templates/talos-machine-configuration-node-controlplane.yaml.tftpl", {
          virtual_shared_ip = var.cluster.virtual_shared_ip
          network_interface = var.cluster.network_interface
        }),
      ]
      // WORKER patches
      (local.CONST.MACHINE_TYPE.WORKER) : [
        templatefile("${path.module}/templates/talos-machine-configuration-node-worker.yaml.tftpl", {}),
      ]
    }[
    each.value.type
    ]
  ))

  depends_on = [proxmox_virtual_environment_vm.this]

  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_vm.this[each.key]]
  }
}

resource "talos_machine_bootstrap" "this" {
  node                 = local.control_plane_node_ips[0]
  endpoint             = local.control_plane_node_ips[0]
  client_configuration = talos_machine_secrets.this.client_configuration

  depends_on = [talos_machine_configuration_apply.this]
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster.name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = local.control_plane_node_ips
  nodes = concat(local.control_plane_node_ips, local.worker_node_ips)
}

data "talos_cluster_health" "this" {
  count = var.cluster.health_check.enabled ? 1 : 0

  skip_kubernetes_checks = var.cluster.health_check.skip_kubernetes_checks
  client_configuration   = data.talos_client_configuration.this.client_configuration
  control_plane_nodes    = local.control_plane_node_ips
  worker_nodes           = local.worker_node_ips
  endpoints              = data.talos_client_configuration.this.endpoints
  timeouts               = var.cluster.health_check.timeouts

  depends_on = [
    talos_machine_configuration_apply.this,
    talos_machine_bootstrap.this
  ]
}

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoint             = local.control_plane_node_ips[0]
  node                 = local.control_plane_node_ips[0]

  depends_on = [talos_machine_bootstrap.this]

  lifecycle {
    replace_triggered_by = [talos_machine_configuration_apply.this]
  }
}