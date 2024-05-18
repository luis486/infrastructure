variable "cluster_name" {
  description = "Name of the AKS cluster"
  default = "aks_cluster"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  default = "MyClusterDNS"
}

variable "rg_name" {
  description = "Name of the Azure Resource Group"
}

variable "rg_location" {
  description = "Location for the AKS cluster"
}


variable "node_pool" {
  description = "Name of the default node pool"
  default = "nodepool"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type = number
  default = 1
}

variable "vm_size" {
  description = "Size of VMs in the default node pool"
  default = "Standard_D2_v2"
}

variable "os_disk_size_gb" {
  description = "Size of the OS disk in GB for nodes in the default node pool"
  type = number
  default = 40
}

variable "vnet_subnet_id" {
  description = "ID of the subnet where the AKS cluster will be deployed"
}

variable "local_file" {
  description = "Name of the kuberneter file"
  default = "kubeconfig"
}

variable "secret_rotation_enabled" {
  description = "Name of the kuberneter file"
}

variable "private_cluster_enabled" {
  description = "Name of the kuberneter file"
}