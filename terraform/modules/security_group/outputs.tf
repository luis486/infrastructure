output "security_group_id" {
  value       = azurerm_network_security_group.storeGroup.id
  description = "The ID of the security group"
}