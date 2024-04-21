# ------------------------ NETWORK -------------------------------------------


resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group
  location = var.azure_region
}

resource "azurerm_virtual_network" "aks_vnet" {
  name                = var.aks_vnet_name
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  address_space       = var.vnetcidr
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks_subnet"
  resource_group_name  = azurerm_resource_group.aks_rg.name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = var.subnetcidr
}


# -------------------------- SECURITY----------------------------------------------

# Creación del grupo de seguridad de red para permitir la comunicación a la vm
resource "azurerm_network_security_group" "main" {
  name                = "vm-security-group"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  security_rule {
    name                       = "vm-ssh-rule"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "vm-access-rule"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5984"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

### -----------------------CONTAINER REGISTRY--------------------- ###

resource "azurerm_container_registry" "main" {
  name                = "myHealthContainerRegistry"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  sku                 = "Basic"
  admin_enabled       = true
}



#------------------------------ KEY VAULT----------------------------------

data "azurerm_client_config" "current" {}

locals {

  diag_resource_list = var.diagnostics != null ? split("/", var.diagnostics.destination) : []
  parsed_diag        = var.diagnostics != null ? {
    log_analytics_id   = contains(local.diag_resource_list, "Microsoft.OperationalInsights") ? var.diagnostics.destination : null
    storage_account_id = contains(local.diag_resource_list, "Microsoft.Storage") ? var.diagnostics.destination : null
    event_hub_auth_id  = contains(local.diag_resource_list, "Microsoft.EventHub") ? var.diagnostics.destination : null
    metric             = var.diagnostics.metrics
    log                = var.diagnostics.logs
  } : {
    log_analytics_id   = null
    storage_account_id = null
    event_hub_auth_id  = null
    metric             = []
    log                = []
  }
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group
  location = var.azure_region

}

resource "azurerm_key_vault" "main" {
  name                = format("%s-kv", lower(var.keyvault_name))
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.sku_name

  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  soft_delete_retention_days      = var.soft_delete_retention_days

  dynamic "network_acls" {
    for_each = var.network_acls != null ? [true] : []
    content {
      bypass                     = var.network_acls.bypass
      default_action             = var.network_acls.default_action
      ip_rules                   = var.network_acls.ip_rules
      virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
    }
  }
}

resource "azurerm_key_vault_access_policy" "main" {
  count        = length(var.access_policies)
  key_vault_id = azurerm_key_vault.main.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = var.access_policies[count.index].object_id

  secret_permissions      = var.access_policies[count.index].secret_permissions
  key_permissions         = var.access_policies[count.index].key_permissions
  certificate_permissions = var.access_policies[count.index].certificate_permissions
  storage_permissions     = var.access_policies[count.index].storage_permissions
}

data "azurerm_monitor_diagnostic_categories" "default" {
  resource_id = azurerm_key_vault.main.id
}

resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  count                          = var.diagnostics != null ? 1 : 0
  name                           = "${var.keyvault_name}-ns-diag"
  target_resource_id             = azurerm_key_vault.main.id
  log_analytics_workspace_id     = local.parsed_diag.log_analytics_id
  eventhub_authorization_rule_id = local.parsed_diag.event_hub_auth_id
  eventhub_name                  = local.parsed_diag.event_hub_auth_id != null ? var.diagnostics.eventhub_name : null
  storage_account_id             = local.parsed_diag.storage_account_id

  dynamic "enabled_log" {
    for_each = {
      for k, v in data.azurerm_monitor_diagnostic_categories.default.log_category_types : k => v
      if contains(local.parsed_diag.log, "all") || contains(local.parsed_diag.log, v)
    }
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.default.metrics
    content {
      category = metric.value
      enabled  = contains(local.parsed_diag.metric, "all") || contains(local.parsed_diag.metric, metric.value)
    }
  }
}

# ----------------------------- API GATEWAY ------------------------------

resource "azurerm_resource_group" "appgw" {
  name     = "appgw"
  location = "West US"
}

resource "azurerm_api_management" "apim-mgt" {
  name                = "apim-mgt"
  location            = azurerm_resource_group.appgw.location
  resource_group_name = azurerm_resource_group.appgw.name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email

  sku_name            = var.sku
}

resource "azurerm_api_management_api" "apim-mgt" {
  name                = "apim-mgt"
  resource_group_name = azurerm_resource_group.appgw.name
  api_management_name = azurerm_api_management.apim-mgt.name
  revision            = var.revision
  display_name        = var.display_name
  path                = var.path
  protocols           = var.protocols
  service_url         = var.service_url

  import {
    content_format = "swagger-link-json"
    content_value  = "http://conferenceapi.azurewebsites.net/?format=json"
  }
}

# ----------------------------- CLUSTER K8S ------------------------------


resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = var.dns_name

  default_node_pool {
    name            = var.agent_pools.name
    node_count      = var.agent_pools.count
    vm_size         = var.agent_pools.vm_size
    os_disk_size_gb = var.agent_pools.os_disk_size_gb
  }

  identity {
    type = "SystemAssigned"
  }


  tags = {
    Environment = "Demo"
  }
}