
output "resource_group_name" {
  value = azurerm_resource_group.argk8s.name
}

# En el archivo outputs.tf del módulo resource_group

output "location" {
  value = azurerm_resource_group.argk8s.location
}