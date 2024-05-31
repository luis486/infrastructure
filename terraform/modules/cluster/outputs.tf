output "cluster_ip" {
  value = azurerm_kubernetes_cluster.aks_cluster.fqdn
}

output "kubelet_identity"{ 
  value = azurerm_kubernetes_cluster.clusterStore.kubelet_identity[0].object_id
  description = "The ID of the Kubernetes Cluster Identity"
}
output "aks_secret_provider"{
  value = azurerm_kubernetes_cluster.clusterStore.key_vault_secrets_provider[0].secret_identity[0].object_id
}
