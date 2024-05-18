

# Ip Publica para asociarla al Api Gateway
resource "azurerm_public_ip" "publicIp" {
  name                = "PublicIp"
  location            = azurerm_resource_group.argk8s.location
  resource_group_name = azurerm_resource_group.argk8s.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
# Virtual Network sobre lo que estara asociado el Api Gateway
resource "azurerm_virtual_network" "apiVnet" {
  name                = "ApiVnet"
  resource_group_name = azurerm_resource_group.argk8s.name
  location            = azurerm_resource_group.argk8s.location
  address_space       = ["10.1.0.0/16"]
}
# Subred en la que estara el Api Gateway
resource "azurerm_subnet" "apiGatewaySubnet" {
  name                 = "apiGatewaySubnet"
  resource_group_name  = azurerm_resource_group.argk8s.name
  virtual_network_name = azurerm_virtual_network.apiVnet.name
  address_prefixes     = ["10.1.10.0/24"]
}
# Virtual Network sobre lo que estara asociado el Cluster
resource "azurerm_virtual_network" "clusterVnet" {
  name                = "myClusterVnet"
  resource_group_name = azurerm_resource_group.argk8s.name
  location            = azurerm_resource_group.argk8s.location
  address_space       = ["10.2.0.0/16"]
}
# Subred en la que estara el Cluster
resource "azurerm_subnet" "clusterSubnet" {
  name                 = "clusterSubnet"
  resource_group_name  = azurerm_resource_group.argk8s.name
  virtual_network_name = azurerm_virtual_network.clusterVnet.name
  address_prefixes     = ["10.2.10.0/24"]