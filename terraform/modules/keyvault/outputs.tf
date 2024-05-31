output "key_vault_id" {
  description = "The ID of the created Azure Key Vault."
  value       = azurerm_key_vault.key_vault_ecommerce.id
}

output "name" {
  description = "The ID of the created Azure Key Vault."
  value       = azurerm_key_vault.key_vault_ecommerce.name
}

output "tenant_id" {
  description = "The ID of the created Azure Key Vault."
  value       = azurerm_key_vault.key_vault_ecommerce.tenant_id
}


output "secrets" {
  description = "The ID of the created Azure Key Vault."
  value = azurerm_key_vault_secret.key_vault_secret[*].value
}
