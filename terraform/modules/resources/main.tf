
# Grupo de recursos sobre lo que se creara todo el codigo
resource "azurerm_resource_group" "argk8s" {
  name     = var.rg_name
  location = var.rg_location
}