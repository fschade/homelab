output "debug" {
  value = module.talos.debug
  sensitive = true
}

output "talos_client_configuration" {
  value     = module.talos.talos_client_configuration
  sensitive = true
}

output "talos_cluster_kubeconfig" {
  value     = module.talos.talos_cluster_kubeconfig
  sensitive = true
}