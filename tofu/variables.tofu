variable "proxmox_username" {
  description = "Username for the Proxmox provider (e.g. root@pam or terraform@pve)"
  type        = string
  sensitive   = true
}

variable "proxmox_password" {
  description = "Password for the Proxmox provider"
  type        = string
  sensitive   = true
}