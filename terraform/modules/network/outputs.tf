output "public_ip_id" { 
    value       = azurerm_public_ip.publicIp.id
}


output "apgw_vnet" {
  value       = azurerm_virtual_network.apiVnet.name
}

output "api_vnet_id" {
  value       = azurerm_virtual_network.apiVnet.id
}

output "apgw_subnet_id" {
  value       = azurerm_subnet.apiGatewaySubnet.id
}

output "cluster_vnet_id" {
  value       = azurerm_virtual_network.clusterVnet.id
}

output "cluster_subnet_id" {
  value       = azurerm_subnet.clusterSubnet.id
}