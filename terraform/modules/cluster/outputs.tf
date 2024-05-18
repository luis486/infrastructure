output "cluster_ip" {
  value = azurerm_kubernetes_cluster.aks_cluster.fqdn
}
