resource "azurerm_container_registry" "container_registry" {
  name                = var.cr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.container_sku
  admin_enabled       = true
}

