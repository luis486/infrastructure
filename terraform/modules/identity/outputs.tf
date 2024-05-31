output "client_id" {
  value = azurerm_user_assigned_identity.ecommerce_identity.client_id
}

output "principal_id" {
  value = azurerm_user_assigned_identity.ecommerce_identity.principal_id
}

output "id" {
  value = azurerm_user_assigned_identity.ecommerce_identity.id
}