resource "kubernetes_namespace_v1" "nginx" {
  metadata {
    name = "nginx"
  }

  depends_on = [time_sleep.talos_cluster_kubeconfig]
}

resource "helm_release" "nginx" {
  name       = "nginx"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx"
  namespace  = kubernetes_namespace_v1.nginx.metadata[0].name

  values = [
    yamlencode({
      service = {
        type = "NodePort"
        nodePorts = {
          http = 30080
        }
      }
    })
  ]

  depends_on = [
    talos_cluster_kubeconfig.this
  ]
}