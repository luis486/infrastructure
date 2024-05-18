resource "azurerm_container_registry" "main" {
  name                = var.cr_name
  resource_group_name = var.rg_name
  location            = var.rg_location
  sku                 = var.container_sku
  admin_enabled       = true
}

