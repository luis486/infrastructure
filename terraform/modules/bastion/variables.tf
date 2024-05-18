variable "bastion_name" {
  description = "The name of the Azure Bastion Host."
}

variable "rg_location" {
  description = "The location of the resource group in which to create the Azure Bastion Host."
}

variable "rg_name" {
  description = "The name of the resource group in which to create the Azure Bastion Host."
}

variable "ip_configuration_name" {
  description = "The name of the IP configuration for the Azure Bastion Host."
}

variable "cluster_subnet_id" {
  description = "The ID of the subnet in which to deploy the Azure Bastion Host."
}

variable "bastion_public_ip" {
  description = "The ID of the public IP address associated with the Azure Bastion Host."
}