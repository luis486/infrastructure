variable "public_ip" {
  description = "Name of the Azure Public IP"
  default = "myFirstPublicIp"
}

variable "rg_location" {
  description = "Location for the Azure resources"
}

variable "rg_name" {
  description = "Name of the Azure Resource Group"
}

variable "bastion_public_ip" {
  description = "Name of the Azure Public IP"
  default = "bastionPublicIP"
}

variable "allocation_method" {
  description = "Allocation method for the Public IP"
  default = "Static"
}

variable "sku" {
  description = "SKU for the Public IP"
  default = "Standard"
}

variable "apgw" {
  description = "Name of the API Virtual Network"
  default = "ApiVnet"
}

variable "apgw_vnet_address_space" {
  description = "Address space for the API Virtual Network"
}

variable "apgw_subnet" {
  description = "Name of the API Gateway Subnet"
  default = "apiGatewaySubnet"
}

variable "apgw_subnet_address_prefixes" {
  description = "Address prefixes for the API Gateway Subnet"
}

variable "cluster_vnet" {
  description = "Name of the Cluster Virtual Network"
  default = "myClusterVnet"
}

variable "cluster_vnet_address_space" {
  description = "Address space for the Cluster Virtual Network"
}

variable "cluster_subnet" {
  description = "Name of the Cluster Subnet"
  default = "clusterSubnet"

}

variable "cluster_subnet_address_prefixes" {
  description = "Address prefixes for the Cluster Subnet"
}

variable "appgw_to_cluster_peering" {
  description = "Name of the peering from AppGW to Cluster VNet"
  default = "AppGWtoClusterVnetPeering"
}

variable "cluster_to_appgw_peering" {
  description = "Name of the peering from Cluster to AppGW VNet"
  default = "ClustertoAppGWVnetPeering"
}