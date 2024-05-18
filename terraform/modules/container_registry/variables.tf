variable "cr_name" {
  description = "The name of the Azure Container Registry."
}

variable "rg_name" {
  description = "The name of the resource group in which to create the Azure Container Registry."
}

variable "rg_location" {
  description = "The location of the resource group in which to create the Azure Container Registry."
}

variable "container_sku" {
  description = "The SKU name of the Azure Container Registry."
  default = "Standard"
}