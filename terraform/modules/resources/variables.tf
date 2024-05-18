variable "rg_name" {
  description = "The name of the resource group in which to create the Azure Container Registry."
  default = "ApiK8sResourceGroup"
}

variable "rg_location" {
  description = "The location of the resource group in which to create the Azure Container Registry."
  default =  "East US"
}