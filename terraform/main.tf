# Para desplegar este ejemplo necesitas primero crear todos los recursos con terraform apply
# Luego debes extrare el id del api gateway ya desplegado con el siguiente comando
# appgwId=$(az network application-gateway show -n myApplicationGateway -g testingApiK8sResourceGroup -o tsv --query "id")
# Luego debes habilitar el controlador ingress y unirlo con dicha api con el comando
# az aks enable-addons -n myCluster -g testingApiK8sResourceGroup -a ingress-appgw --appgw-id $appgwId
# Luego, deberas mover el archivo kubeconfig a tu contexto local para poder usar los comandos
# de kubectl en tu pc y comunicarse directamente con la nube
# con mv kubeconfig ~/.kube/config se realiza dicha accion
# luego puedes crear con kubectl el cluster-example.yaml o obtenerlo del repo oficial
# kubectl apply -f https://raw.githubusercontent.com/Azure/application-gateway-kubernetes-ingress/master/docs/examples/aspnetapp.yaml 
# luego kubectl get ingress para ver su ip o en puedes ir a azure, ver el recurso api gateway y la 
# DIR IP FRONTEND que aparezca en el overview de tu apigateway deberia ser ahora el punto de acceso a
# los recursos creados en el cluster


# --------------------------------- RECURSOS ---------------------------------

# Grupo de recursos sobre lo que se creara todo el codigo
resource "azurerm_resource_group" "argk8s" {
  name     = "ApiK8sResourceGroup"
  location = "East US"
}

# ----------------------------------- RED -----------------------------------------

# Ip Publica para asociarla al Api Gateway
resource "azurerm_public_ip" "publicIp" {
  name                = "PublicIp"
  location            = azurerm_resource_group.argk8s.location
  resource_group_name = azurerm_resource_group.argk8s.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
# Virtual Network sobre lo que estara asociado el Api Gateway
resource "azurerm_virtual_network" "apiVnet" {
  name                = "ApiVnet"
  resource_group_name = azurerm_resource_group.argk8s.name
  location            = azurerm_resource_group.argk8s.location
  address_space       = ["10.1.0.0/16"]
}
# Subred en la que estara el Api Gateway
resource "azurerm_subnet" "apiGatewaySubnet" {
  name                 = "apiGatewaySubnet"
  resource_group_name  = azurerm_resource_group.argk8s.name
  virtual_network_name = azurerm_virtual_network.apiVnet.name
  address_prefixes     = ["10.1.1.0/24"]
}
# Virtual Network sobre lo que estara asociado el Cluster
resource "azurerm_virtual_network" "clusterVnet" {
  name                = "myClusterVnet"
  resource_group_name = azurerm_resource_group.argk8s.name
  location            = azurerm_resource_group.argk8s.location
  address_space       = ["10.2.0.0/16"]
}
# Subred en la que estara el Cluster
resource "azurerm_subnet" "clusterSubnet" {
  name                 = "clusterSubnet"
  resource_group_name  = azurerm_resource_group.argk8s.name
  virtual_network_name = azurerm_virtual_network.clusterVnet.name
  address_prefixes     = ["10.2.1.0/24"]
}

#----------------------------- VARIABLES LOCALES -------------------------------------

locals {
  # Aqui se definen variables locales asociados a varios recursos de red para mantener
  # la lebibilidad, consistencia y reutilizacion de dichas variables en el codigo
  backend_address_pool_name      = "${azurerm_virtual_network.apiVnet.name}-beap"
  frontend_port_HTTP_name        = "${azurerm_virtual_network.apiVnet.name}-fe_HTTP_port"
  frontend_port_HTTPS_name       = "${azurerm_virtual_network.apiVnet.name}-fe_HTTPS_port"
  frontend_ip_configuration_name = "${azurerm_virtual_network.apiVnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.apiVnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.apiVnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.apiVnet.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.apiVnet.name}-rdrcfg"
}

# Creación del grupo de seguridad de red para permitir la comunicación a la vm

resource "azurerm_network_security_group" "vm" {
  name                = "vm-security-group"
  location            = azurerm_resource_group.argk8s.location
  resource_group_name = azurerm_resource_group.argk8s.name

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

# ----------------------------------- API GATEWAY -----------------------------------

resource "azurerm_application_gateway" "myApplicationGateway" {
  name                = "myApplicationGateway"
  resource_group_name = azurerm_resource_group.argk8s.name
  location            = azurerm_resource_group.argk8s.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    # Aqui se configura la dir ip del Api Gateway
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.apiGatewaySubnet.id
  }

  frontend_ip_configuration {
    # Aqui se define la configuracion de la direccion IP frontal, en este caso, asociándola a una dirección IP publica
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.publicIp.id
  }

  frontend_port {
    # Aqui se especifica el puerto frontal para HTTP
    name = local.frontend_port_HTTP_name
    port = 80
  }

  backend_address_pool {
    # Crea un grupo de direcciones de backend para enrutar el trafico
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    # Configura los ajustes de HTTP, como el puerto, el protocolo, y el tiempo de espera de la solicitud
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    # Define un escucha HTTP que se asocia con la configuración de direccion IP frontal y el puerto frontal
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_HTTP_name
    protocol                       = "Http"
  }

  request_routing_rule {
    # Establece una regla de enrutamiento que vincula el escucha HTTP, el grupo de direcciones de backend y la configuración de HTTP
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    priority                   = 9
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}

#-------------------------------CONTAINER-REGISTRY---------------------------

resource "azurerm_container_registry" "main" {
  name                = "myHealthContainerRegistry"
  resource_group_name = azurerm_resource_group.argk8s.name
  location            = azurerm_resource_group.argk8s.location
  sku                 = "Basic"
  admin_enabled       = true
}


#------------------------------ KEY VAULT----------------------------------






# ----------------------------- CLUSTER K8S ------------------------------


resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "aks_cluster"
  location            = azurerm_resource_group.argk8s.location
  resource_group_name = azurerm_resource_group.argk8s.name
  dns_prefix          = "MyClusterDNS"

  # Configuracion del grupo de nodos por defecto
  default_node_pool {
    name            = "nodepool"
    node_count      = 1
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 40
    vnet_subnet_id  = azurerm_subnet.clusterSubnet.id
  }

  identity {
    type = "SystemAssigned"
  }
}

# Generacion del archivo kubeconfig para poder linkear kubectl de forma local con el cluster en la nube
resource "local_file" "kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.aks_cluster]
  filename   = "kubeconfig"
  content    = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
}



#--------------------------------- UNIÓN REDES VIRTUALES ----------------------------------------- 

# Dado que ha desplegado el clúster AKS en su propia red virtual y la puerta de enlace de 
# aplicaciones en otra red virtual, tendrá que unir las dos redes virtuales para que el tráfico 
# fluya desde la puerta de enlace de aplicaciones a los pods del clúster.

# Creacion de la relacion de confianza entre las redes virtuales del cluster y de la aplicacion
resource "azurerm_virtual_network_peering" "AppGWtoClusterVnetPeering" {
  name                         = "AppGWtoClusterVnetPeering"
  resource_group_name          = azurerm_resource_group.argk8s.name
  virtual_network_name         = azurerm_virtual_network.apiVnet.name
  remote_virtual_network_id    = azurerm_virtual_network.clusterVnet.id
  allow_virtual_network_access = true
}

# Creacion de la relacion de confianza entre las redes virtuales del cluster y de la aplicacion
resource "azurerm_virtual_network_peering" "ClustertoAppGWVnetPeering" {
  name                         = "ClustertoAppGWVnetPeering"
  resource_group_name          = azurerm_resource_group.argk8s.name
  virtual_network_name         = azurerm_virtual_network.clusterVnet.name
  remote_virtual_network_id    = azurerm_virtual_network.apiVnet.id
  allow_virtual_network_access = true
}



