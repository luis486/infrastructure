resource "azurerm_user_assigned_identity" "ecommerce_identity" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
}