locals {
  CONST = {
    NOOP = "noop"
    MACHINE_TYPE = {
      CONTROL_PLANE = "controlplane"
      WORKER        = "worker"
    }
  }

  kubernetes_config = {
    host = local.cluster_endpoint
    client_certificate = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate)
    client_key = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key)
    cluster_ca_certificate = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate)
  }

  control_plane_node_names = sort([
    for name, node in var.nodes : name
    if node.type == local.CONST.MACHINE_TYPE.CONTROL_PLANE
  ])

  control_plane_node_ips = [
    for name in local.control_plane_node_names : var.nodes[name].vm.ip
  ]

  worker_node_names = sort([
    for name, node in var.nodes : name
    if node.type == local.CONST.MACHINE_TYPE.WORKER
  ])

  worker_node_ips = [
    for name in local.worker_node_names : var.nodes[name].vm.ip
  ]

  cluster_endpoint = "https://${coalesce(var.cluster.endpoint, var.cluster.virtual_shared_ip, local.control_plane_node_names[0])}:6443"
}