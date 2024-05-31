#----------------------------- VARIABLES LOCALES -------------------------------------

data "azurerm_client_config" "current" {}

locals {
  # Aqui se definen variables locales asociados a varios recursos de red para mantener
  # la legibilidad, consistencia y reutilizacion de dichas variables en el codigo
  backend_address_pool_name      = "${module.network.apgw_vnet}-beap"
  frontend_port_HTTP_name        = "${module.network.apgw_vnet}-fe_HTTP_port"
  frontend_port_HTTPS_name       = "${module.network.apgw_vnet}-fe_HTTPS_port"
  frontend_ip_configuration_name = "${module.network.apgw_vnet}-feip"
  http_setting_name              = "${module.network.apgw_vnet}-be-htst"
  listener_name                  = "${module.network.apgw_vnet}-httplstn"
  request_routing_rule_name      = "${module.network.apgw_vnet}-rqrt"
  redirect_configuration_name    = "${module.network.apgw_vnet}-rdrcfg"
  current_user_id                = coalesce(null, data.azurerm_client_config.current.object_id)
}

# --------------------------------- RECURSOS ---------------------------------

module "resources" {
  source              = "./modules/resources"
  resource_group_name = "ApiK8sResourceGroup"
  location            = "East US"
}

#-------------------------------CONTAINER-REGISTRY---------------------------

module "container_registry" {
  source              = "./modules/container_registry"
  cr_name             = "myPLDFirstContainerRegistry"
  resource_group_name = module.resources.resource_group_name
  location            = module.resources.location

}

# ----------------------------------- RED -----------------------------------------

module "network" {
  source                          = "./modules/network"
  resource_group_name             = module.resources.resource_group_name
  location                        = module.resources.location
  apgw_vnet_address_space         = ["10.1.0.0/16"]
  apgw_subnet_address_prefixes    = ["10.1.10.0/24"]
  cluster_vnet_address_space      = ["10.2.0.0/16"]
  cluster_subnet_address_prefixes = ["10.2.10.0/24"]
}

#-------------------------------------- SECURITY---------------------------------------

module "security_group" {
  source                  = "./modules/security_group"
  security_group_name     = "SecurityGroupPLD"
  resource_group_location = module.resources.location
  resource_group_name     = module.resources.resource_group_name
}

# ----------------------------------- API GATEWAY -----------------------------------

module "appgw" {
  source                                          = "./modules/appgw"
  resource_group_name                             = module.resources.resource_group_name
  location                                        = module.resources.location
  subnet_id                                       = module.network.apgw_subnet_id
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

#-------------------------------IDENTITY--------------------------------------------

module "identity" {
  source              = "./modules/identity"
  name                = "myUserAssignedIdentity_Ecommerce"
  resource_group_name = module.resources.resource_group_name
  location            = module.resources.location
}

#------------------------------ KEY VAULT----------------------------------

module "keyvault" {
  source                              = "./modules/keyvault"
  key_vault_name                      = "myPLDKeyVault"
  resource_group_name                 = module.resources.resource_group_name
  location                            = module.resources.location
  tenant_id                           = data.azurerm_client_config.current.tenant_id
  object_id                           = local.current_user_id
  key_permissions                     = ["Get", "Create", "List", "Delete", "Purge", "Recover", "SetRotationPolicy", "GetRotationPolicy"]
  secret_permissions                  = ["Get", "Set", "List", "Delete", "Purge", "Recover"]
  certificate_permissions             = ["Get"]
  sku_name                            = "standard"
  secret_names                        = ["mySecret1", "mySecret2"]
  secret_values                       = ["miprimeracontra1!", "misegundacontra2!"]
  key_names                           = ["myPLDKey1", "myPLDKey2"]
  key_types                           = ["RSA", "RSA"]
  key_sizes                           = [2048, 2048]
  key_opts                            = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
  time_before_expiry                  = "P30D"
  expire_after                        = "P90D"
  notify_before_expiry                = "P29D"
  user_assigned_identity_principal_id = module.identity.principal_id
  aks_secret_provider_id              = module.cluster.aks_secret_provider
}


# ----------------------------- CLUSTER K8S ------------------------------


module "cluster" {
  source                  = "./modules/cluster"
  resource_group_name     = module.resources.resource_group_name
  location                = module.resources.location
  vnet_subnet_id          = module.network.cluster_subnet_id
  secret_rotation_enabled = true
  private_cluster_enabled = true
}
