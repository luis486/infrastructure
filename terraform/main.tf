provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

locals {
  current_user_id  = coalesce(null, data.azurerm_client_config.current.object_id)
}
module "resource_group" {
  source              = "./modules/resource_group"
  resource_group_name = "${var.np}-Ecommerce-Company"
  location            = "East US"
}

module "networking" {
  source                              = "./modules/networking"
  resource_group_name                 = module.resource_group.resource_group_name
  location                            = module.resource_group.location
  public_ip_name                      = "${var.np}ApiPublicIp"
  allocation_method                   = "Static"
  sku                                 = "Standard"
  api_vnet_name                       = "${var.np}ApiVnet"
  api_vnet_address_space              = ["10.1.0.0/16"]
  api_gateway_subnet_name             = "${var.np}ApiGwSubnet"
  api_gateway_subnet_address_prefixes = ["10.1.1.0/24"]
  cluster_vnet_name                   = "${var.np}ClusterVnet"
  cluster_vnet_address_space          = ["10.2.0.0/16"]
  cluster_subnet_name                 = "${var.np}ClusterSubnet"
  cluster_subnet_address_prefixes     = ["10.2.1.0/24"]
  appgw_to_cluster_peering_name       = "${var.np}ApiClusterVnetPeering"
  cluster_to_appgw_peering_name       = "${var.np}ClusterApiVnetPeering"
}

module "application_gateway" {
  source                                          = "./modules/application_gateway"
  application_gateway_name                        = "${var.np}-myApplicationGateway"
  resource_group_name                             = module.resource_group.resource_group_name
  location                                        = module.resource_group.location
  sku_name                                        = "Standard_v2"
  sku_tier                                        = "Standard_v2"
  sku_capacity                                    = 2
  gateway_ip_configuration_name                   = "${var.np}-appGatewayIpConfig"
  subnet_id                                       = module.networking.api_gateway_subnet_id
  frontend_ip_configuration_name                  = "${var.np}-fipcn"
  public_ip_address_id                            = module.networking.public_ip_id
  frontend_port_name                              = "${var.np}-fpn"
  frontend_port_port                              = 80
  backend_address_pool_name                       = "${var.np}-bapn"
  backend_http_settings_name                      = "${var.np}-bhsn"
  cookie_based_affinity                           = "Disabled"
  backend_http_settings_port                      = 80
  backend_http_settings_protocol                  = "Http"
  backend_http_settings_request_timeout           = 60
  http_listener_name                              = "${var.np}-hln"
  http_listener_frontend_ip_configuration_name    = "${var.np}-fipcn"
  http_listener_frontend_port_name                = "${var.np}-fpn"
  http_listener_protocol                          = "Http"
  request_routing_rule_name                       = "${var.np}-rrrn"
  request_routing_rule_rule_type                  = "Basic"
  request_routing_rule_priority                   = 9
  request_routing_rule_http_listener_name         = "${var.np}-hln"
  request_routing_rule_backend_address_pool_name  = "${var.np}-bapn"
  request_routing_rule_backend_http_settings_name = "${var.np}-bhsn"
}


module "aks_cluster" {
  source                  = "./modules/aks_cluster"
  cluster_name            = "${var.np}-EcommerceCluster"
  resource_group_name     = module.resource_group.resource_group_name
  location                = module.resource_group.location
  dns_prefix              = "${var.np}-DnsCluster"
  node_pool_name          = "nodepool"
  node_count              = 2
  vm_size                 = "Standard_D2_v2" # Cambiar a un tamaño mayor
  os_disk_size_gb         = 40
  vnet_subnet_id          = module.networking.cluster_subnet_id
  network_plugin          = "azure"
  identity_type           = "SystemAssigned"
  local_file_name         = "${var.np}-kubesystem"
  secret_rotation_enabled = true
}

module "key_vault" {
  source                              = "./modules/key_vault"
  key_vault_name                      = "${var.np}-KvEcommerce123"
  resource_group_name                 = module.resource_group.resource_group_name
  location                            = module.resource_group.location
  tenant_id                           = data.azurerm_client_config.current.tenant_id
  enabled_for_disk_encryption         = true
  purge_protection_enabled            = false
  soft_delete_retention_days          = 7
  sku_name                            = "standard"
  object_id                           = local.current_user_id
  key_permissions                     = ["Get", "Create", "List", "Delete", "Purge", "Recover", "SetRotationPolicy", "GetRotationPolicy"]
  secret_permissions                  = ["Get", "Set", "List", "Delete", "Purge", "Recover"]
  certificate_permissions             = ["Get"]
  secret_names                        = ["NEXT-PUBLIC-CLERK-PUBLISHABLE-KEY", "CLERK-SECRET-KEY", "NEXT-PUBLIC-CLERK-SIGN-IN-URL", "NEXT-PUBLIC-CLERK-AFTER-SIGN-IN-URL", "DATABASE-URL", "NEXT-PUBLIC-CLOUDINARY-CLOUD-NAME", "NEXT-PUBLIC-CLERK-SIGN-UP-URL", "NEXT-PUBLIC-CLERK-AFTER-SIGN-UP-URL", "CLOUDINARY-PRESET-NAME", "FRONTEND-STORE-URL", "STRIPE-API-KEY", "STRIPE-WEBHOOK-SECRET", "NEXT-PUBLIC-API-URL", "REACT-EDITOR", "BILLBOARD-ID"]
  secret_values                       = ["pk_test_Y2FwaXRhbC1odW1wYmFjay01NC5jbGVyay5hY2NvdW50cy5kZXYk", "sk_test_M41hUtSCghLofhQpfdby0kGTY6j06Aa1SpJuC3HVnA", "/sign-in", "/", "mysql://admin:Pass123.@mysql:3306/ecommerce_db", "dytwq4xsw", "/sign-up", "/", "rl1uzqmr", "http://ecommerce-store:3001", "sk_test_51PO94nBr9QdWwf17VX0iiy5xLxwqs76mEaYkETOxEP1VHUG7qx9xJvm7g4A9PgQZRWWjirc8hhKYP0JxwormvzM10031eQM9yY", "whsec_2e8232ce37563694ff7ab24cc639b87be827081ca5ff366d0faa88c51fe03f59", "http://ecommerce-admin:3000/api/e63d3293-a004-4924-891f-6a4d85483f38", "atom", "feb6167d-6c6c-416c-9c28-b0e8e6e56bca"]
  key_names                           = ["ecommerceKey1", "ecommerceKey1"]
  key_types                           = ["RSA", "RSA"]
  key_sizes                           = [2048, 2048]
  key_opts                            = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
  time_before_expiry                  = "P30D"
  expire_after                        = "P90D"
  notify_before_expiry                = "P29D"
  user_assigned_identity_principal_id = module.identity.principal_id
  aks_secret_provider_id              = module.aks_cluster.secret_provider
}


module "identity" {
  source              = "./modules/identity"
  name                = "${var.np}-ecommerceIdentity"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.location
}



module "container_registry" {
  source                  = "./modules/container_registry"
  container_name          = "myldpacontainerregistry"
  resource_group_name     = module.resource_group.resource_group_name
  resource_group_location = module.resource_group.location
  container_sku           = "Standard"
  admin_enabled           = false
}

module "role_assignment" {
  source                           = "./modules/role_assignment"
  principal_id                     = module.aks_cluster.principal_id
  role_definition_name             = "AcrPull"
  scope                            = module.container_registry.scope
  skip_service_principal_aad_check = true
  scope_key_vault                  = module.key_vault.key_vault_id
  role_definition_name_key_vault   = "Key Vault Secrets User"
  principal_id_key_vault           = module.identity.principal_id
}


output "resource_group_name" {
  value = module.resource_group.resource_group_name
}

output "application_gateway_name" {
  value = module.application_gateway.application_gateway_name
}

output "cluster_name" {
  value = module.aks_cluster.cluster_name
}

output "acr_name" {
  value = module.container_registry.name
}


resource "null_resource" "execute_script" {
  depends_on = [
    module.application_gateway,
    module.key_vault,
    module.aks_cluster,
    module.role_assignment,
    module.container_registry,
    module.networking,
    module.resource_group
  ]

  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "chmod +x init-script.sh && ./init-script.sh"
  }
}