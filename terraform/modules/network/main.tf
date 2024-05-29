

# Ip Publica para asociarla al Api Gateway
resource "azurerm_public_ip" "publicIp" {
  name                = var.public_ip
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = var.allocation_method
  sku                 = var.sku
}


# Virtual Network sobre lo que estara asociado el Api Gateway
resource "azurerm_virtual_network" "apiVnet" {
  name                = var.apgw_vnet
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.apgw_vnet_address_space
}


# Subred en la que estara el Api Gateway
resource "azurerm_subnet" "apiGatewaySubnet" {
  name                 = var.apgw_subnet
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.apiVnet.name
  address_prefixes     = var.apgw_subnet_address_prefixes
}

# Virtual Network sobre lo que estara asociado el Cluster
resource "azurerm_virtual_network" "clusterVnet" {
  name                = var.cluster_vnet
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.cluster_vnet_address_space
}

# Subred en la que estara el Cluster
resource "azurerm_subnet" "clusterSubnet" {
  name                 = var.cluster_subnet
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.clusterVnet.name
  address_prefixes     = var.cluster_subnet_address_prefixes
}


# Azure Virtual Network Peering permite conectar redes virtuales (VNets) en Azure, facilitando la comunicación entre ellas con una latencia mínima y sin la
# necesidad de utilizar gateways o túneles VPN.

# Dado que ha desplegado el clúster AKS en su propia red virtual y la puerta de enlace de 
# aplicaciones en otra red virtual, tendrá que unir las dos redes virtuales para que el tráfico 
# fluya desde la puerta de enlace de aplicaciones a los pods del clúster.


resource "azurerm_virtual_network_peering" "AppGWtoClusterVnetPeering" {
  name                         = var.appgw_to_cluster_peering
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.apiVnet.name
  remote_virtual_network_id    = azurerm_virtual_network.clusterVnet.id
  allow_virtual_network_access = true
}

# Estos dos recursos juntos crean una conexión bidireccional entre las 
# redes virtuales apiVnet y clusterVnet

resource "azurerm_virtual_network_peering" "ClustertoAppGWVnetPeering" {
  name                         = var.cluster_to_appgw_peering
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.clusterVnet.name
  remote_virtual_network_id    = azurerm_virtual_network.apiVnet.id
  allow_virtual_network_access = true
}