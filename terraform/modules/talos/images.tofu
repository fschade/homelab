resource "proxmox_virtual_environment_download_file" "this" {
  for_each = {
    for mapping in distinct([
      for _, node in var.nodes : {
        node_name    = node.vm.datacenter.node
        datastore_id = node.vm.image.datastore_id
        iso          = node.server.talos.iso
        talos_version = node.server.talos.version
      }
    ]) : join("/", [mapping.node_name, mapping.datastore_id, mapping.talos_version]) => mapping
  }

  node_name    = each.value.node_name
  content_type = "iso"
  datastore_id = each.value.datastore_id
  url          = each.value.iso
  file_name = join("-", [
    "talos",
    each.value.talos_version,
    basename(each.value.iso)
  ])
}