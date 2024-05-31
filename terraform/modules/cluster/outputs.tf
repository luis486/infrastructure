output "cluster_ip" {
  value = azurerm_kubernetes_cluster.aks_cluster.fqdn
}

output "kubelet_identity"{ 
  value = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity[0].object_id
  description = "The ID of the Kubernetes Cluster Identity"
}
output "aks_secret_provider"{
  value = azurerm_kubernetes_cluster.aks_cluster.key_vault_secrets_provider[0].secret_identity[0].object_id
}

output "client_certificate-Store" {
  value     = azurerm_kubernetes_cluster.aks_cluster.kube_config[0].client_certificate
  sensitive = true
}

output "kube_config-Store" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw

  sensitive = true
}
