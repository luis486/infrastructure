
# Grupo de recursos sobre lo que se creara todo el codigo
resource "azurerm_resource_group" "argk8s" {
  name     = "ApiK8sResourceGroup"
  location = "East US"
}