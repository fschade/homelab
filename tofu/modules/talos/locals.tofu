locals {
  CONST = {
    NOOP = "noop"
    MACHINE_TYPE = {
      CONTROL_PLANE = "controlplane"
      WORKER        = "worker"
    }
  }

  control_plane_node_names = sort([
    for id, node in var.nodes : id
    if node.type == local.CONST.MACHINE_TYPE.CONTROL_PLANE
  ])

  control_plane_node_ips = [
    for id in local.control_plane_node_names : var.nodes[id].ip
  ]

  worker_node_names = sort([
    for id, node in var.nodes : id
    if node.type == local.CONST.MACHINE_TYPE.WORKER
  ])

  worker_node_ips = [
    for id in local.worker_node_names : var.nodes[id].ip
  ]

  custer_endpoint = "https://${coalesce(var.cluster.virtual_shared_ip, local.control_plane_node_names[0])}:6443"
}