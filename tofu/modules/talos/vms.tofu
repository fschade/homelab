resource "proxmox_virtual_environment_vm" "this" {
  for_each = var.nodes

  node_name = each.value.vm.datacenter.node
  name      = each.value.name
  vm_id         = each.value.vm.id

  on_boot = true
  tags = distinct(concat(["terraform", "talos", var.cluster.name], each.value.vm.labels))

  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  bios          = "ovmf"
  migrate = true // fails if cdrom is attached

  agent {
    enabled = true
    trim    = true
  }

  cpu {
    sockets = each.value.vm.cpu.sockets
    cores   = each.value.vm.cpu.cores
    type    = each.value.vm.cpu.type
  }

  memory {
    dedicated = each.value.vm.memory.dedicated
  }

  network_device {
    model = "virtio"
  }

  efi_disk {
    datastore_id = each.value.vm.disk.datastore_id
    file_format  = "raw"
    type         = "4m"
  }

  disk {
    datastore_id = each.value.vm.disk.datastore_id
    interface    = "scsi0"
    cache        = "writethrough"
    discard      = "on"
    ssd          = true
    file_format  = "raw"
    size         = each.value.vm.disk.size
    file_id      = proxmox_virtual_environment_download_file.this[sha256(jsonencode({
      node_name     = each.value.vm.datacenter.node
      datastore_id = each.value.vm.image.datastore_id
      talos_version = each.value.server.talos.version
    }))].id
  }

  boot_order = ["scsi0"]

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 6.X.
  }

  initialization {
    datastore_id = each.value.vm.disk.datastore_id

    dynamic "dns" {
      for_each = try(each.value.vm.dns.servers, null) != null ? { "enabled" = each.value.vm.dns.servers } : {}
      content {
        servers = each.value.vm.dns.servers
      }
    }

    ip_config {
      ipv4 {
        address = "${each.value.ip}/${var.cluster.subnet_mask}"
        gateway = var.cluster.gateway
      }
    }
  }
}

