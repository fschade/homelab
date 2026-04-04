resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "this" {
  for_each = var.nodes

  talos_version      = each.value.server.talos.version
  kubernetes_version = each.value.server.kubernetes.version

  cluster_name     = var.cluster.name
  machine_type     = each.value.type
  cluster_endpoint = local.cluster_endpoint
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  config_patches = compact(concat(
    // global patches
    [
      templatefile("${path.module}/templates/talos-machine-configuration-common.yaml.tftpl", {
        ip                 = each.value.vm.ip
        subnet_mask        = each.value.vm.subnet_mask
        gateway            = each.value.vm.gateway
        hostname           = each.value.name
        zone               = each.value.vm.datacenter.node
        mac_address        = each.value.vm.mac_address
        network_interface  = each.value.vm.network_interface
        install_image      = each.value.server.talos.installer
        region             = var.cluster.name
        kubernetes_version = each.value.server.kubernetes.version
      })
    ],
    {
      // CONTROL_PLANE patches
      (local.CONST.MACHINE_TYPE.CONTROL_PLANE) : [
        templatefile("${path.module}/templates/talos-machine-configuration-controlplane.yaml.tftpl", {
          virtual_shared_ip = var.cluster.virtual_shared_ip
          network_interface = each.value.vm.network_interface
          allow_scheduling_on_control_planes = var.cluster.allow_scheduling_on_control_planes
        }),
      ]
      // WORKER patches
      (local.CONST.MACHINE_TYPE.WORKER) : [
        templatefile("${path.module}/templates/talos-machine-configuration-worker.yaml.tftpl", {}),
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
  node                        = each.value.vm.ip
  apply_mode                  = "auto"

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
  node                 = local.control_plane_node_ips[0]

  depends_on = [talos_machine_bootstrap.this]

  lifecycle {
    replace_triggered_by = [talos_machine_configuration_apply.this]
  }
}

resource "time_sleep" "talos_cluster_kubeconfig" {
  depends_on = [
    data.talos_cluster_health.this,
    talos_cluster_kubeconfig.this
  ]
  create_duration = "30s"
}