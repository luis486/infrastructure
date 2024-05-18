resource "azurerm_bastion_host" "bastion_host" {
  name                = var.bastion_name
  location            = var.rg_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                 = var.ip_configuration_name
    subnet_id            = var.cluster_subnet_id
    public_ip_address_id = var.bastion_public_ip
  }
}