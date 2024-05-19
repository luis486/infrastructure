#----------------------------- VARIABLES LOCALES -------------------------------------

data "azurerm_client_config" "current" {}

locals {
  # Aqui se definen variables locales asociados a varios recursos de red para mantener
  # la lebibilidad, consistencia y reutilizacion de dichas variables en el codigo
  backend_address_pool_name      = "${module.networking.api_vnet_name}-beap"
  frontend_port_HTTP_name        = "${module.networking.api_vnet_name}-fe_HTTP_port"
  frontend_port_HTTPS_name       = "${module.networking.api_vnet_name}-fe_HTTPS_port"
  frontend_ip_configuration_name = "${module.networking.api_vnet_name}-feip"
  http_setting_name              = "${module.networking.api_vnet_name}-be-htst"
  listener_name                  = "${module.networking.api_vnet_name}-httplstn"
  request_routing_rule_name      = "${module.networking.api_vnet_name}-rqrt"
  redirect_configuration_name    = "${module.networking.api_vnet_name}-rdrcfg"
  current_user_id                = coalesce(null, data.azurerm_client_config.current.object_id)
}

# --------------------------------- RECURSOS ---------------------------------

module "resources" {
  source      = "./modules/resources"
  rg_name     = "ApiK8sResourceGroup"
  rg_location = "East US"
}

#-------------------------------CONTAINER-REGISTRY---------------------------

module "container_registry" {
  source                  = "./modules/container_registry"
  container_name          = "myPLDFirstContainerRegistry"
  resource_group_name     = module.resource_group.resource_group_name
  resource_group_location = module.resource_group.location

}

# ----------------------------------- RED -----------------------------------------

module "network" {
  source                              = "./modules/network"
  resource_group                      = module.resources.rg_name
  location                            = module.resources.location
  api_vnet_address_space              = ["10.1.0.0/16"]
  api_gateway_subnet_address_prefixes = ["10.1.10.0/24"]
  cluster_vnet_address_space          = ["10.2.0.0/16"]
  cluster_subnet_address_prefixes     = ["10.2.10.0/24"]
}


# ----------------------------------- API GATEWAY -----------------------------------

module "appgw" {
  source                                          = "./modules/appgw"
  resource_group_name                             = module.resources.rg_name
  location                                        = module.resources.rg_location
  subnet_id                                       = module.network.api_gateway_subnet_id
  frontend_ip_configuration_name                  = local.frontend_ip_configuration_name
  public_ip_address_id                            = module.network.public_ip_id
  frontend_port_name                              = local.frontend_port_HTTP_name
  backend_address_pool_name                       = local.backend_address_pool_name
  backend_http_settings_name                      = local.http_setting_name
  http_listener_name                              = local.listener_name
  http_listener_frontend_ip_configuration_name    = local.frontend_ip_configuration_name
  http_listener_frontend_port_name                = local.frontend_port_HTTP_name
  request_routing_rule_name                       = local.request_routing_rule_name
  request_routing_rule_http_listener_name         = local.listener_name
  request_routing_rule_backend_address_pool_name  = local.backend_address_pool_name
  request_routing_rule_backend_http_settings_name = local.http_setting_name
}

#------------------------------ KEY VAULT----------------------------------

module "key_vault" {
  source                      = "./modules/keyvault"
  key_vault_name              = "myPLDKeyVault"
  resource_group_name         = module.resources.rg_name
  location                    = module.resources.rg.location
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  object_id                   = local.current_user_id
  key_permissions             = ["Get", "Create", "List", "Delete", "Purge", "Recover", "SetRotationPolicy", "GetRotationPolicy"]
  secret_permissions          = ["Get", "Set", "List", "Delete", "Purge", "Recover"]
  certificate_permissions     = ["Get"]
  secret_names                = ["mySecret1", "mySecret2"]
  secret_values               = ["miprimeracontra1!", "misegundacontra2!"]
  key_names                   = ["myPLDKey1", "myPLDKey2"]
  key_types                   = ["RSA", "RSA"]
  key_sizes                   = [2048, 2048]
  key_opts                    = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
  time_before_expiry          = "P30D"
  expire_after                = "P90D"
  notify_before_expiry        = "P29D"
}


# ----------------------------- CLUSTER K8S ------------------------------


module "cluster" {
  source                  = "./modules/cluster"
  resource_group          = module.resources.rg_name
  location                = module.resources.rg_location
  vnet_subnet_id          = module.network.cluster_subnet_id
  secret_rotation_enabled = true
  private_cluster_enabled = true
}


