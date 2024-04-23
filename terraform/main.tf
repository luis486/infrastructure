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

#-------------------------------CONTAINER-REGISTRY---------------------------

#------------------------------ KEY VAULT----------------------------------



# ----------------------------- API GATEWAY ------------------------------


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