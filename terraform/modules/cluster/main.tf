resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  # Configuracion del grupo de nodos por defecto
  default_node_pool {
    name            = var.node_pool
    node_count      = var.node_count
    vm_size         = var.vm_size
    os_disk_size_gb = var.os_disk_size_gb
    vnet_subnet_id  = var.vnet_subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  key_vault_secrets_provider {
    # update the secrets on a regular basis
    secret_rotation_enabled = var.secret_rotation_enabled
  }

  
}

# Generacion del archivo kubeconfig para poder linkear kubectl de forma local con el cluster en la nube
resource "local_file" "kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
  filename   = var.local_file
  content    = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
}
