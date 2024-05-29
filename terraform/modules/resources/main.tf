
# Grupo de recursos sobre lo que se creara todo el codigo
resource "azurerm_resource_group" "argk8s" {
  name                  = var.resource_group_name
  location              = var.location
}