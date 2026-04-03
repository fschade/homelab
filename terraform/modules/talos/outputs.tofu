output "debug" {
  value = local.CONST.NOOP
  sensitive = true
}

output "talos_client_configuration" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}

output "talos_cluster_kubeconfig" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}