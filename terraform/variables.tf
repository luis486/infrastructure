variable "aks_vnet_name" {
  type = string
}

#------------- VARIABLES KEY VAULT----------------------------


variable "keyvault_rg" {
  type = string
}
variable "keyvault_name" {
  type = string
}

variable "sku_name" {
  description = "The Name of the SKU used for this Key Vault. Possible values are `standard` and `premium`."
  default     = "standard"
}

variable "network_acls" {
  description = "Network rules to apply to key vault."
  type = object({
    bypass                     = string,
    default_action             = string,
    ip_rules                   = list(string),
    virtual_network_subnet_ids = list(string),
  })
  default = null
}


variable "access_policies" {
  description = "Map of access policies for an object_id (user, service principal, security group) to backend."
  type = list(object({
    object_id               = string,
    certificate_permissions = list(string),
    key_permissions         = list(string),
    secret_permissions      = list(string),
    storage_permissions     = list(string),
  }))
  default = []
}

variable "diagnostics" {
  description = "Diagnostic settings for those resources that support it. See README.md for details on configuration."
  type = object({
    destination   = string,
    eventhub_name = string,
    logs          = list(string),
    metrics       = list(string)
  })
  default = null
}

variable "enabled_for_deployment" {
  description = "Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. Defaults to `false`."
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. Defaults to `false`."
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault. Defaults to `false`."
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "The number of days that items should be retained for once soft-deleted."
  type        = number
  default     = 7
}

variable "sshkvsecret" {
  type = string
}

variable "clientidkvsecret" {
  type = string
}

variable "vnetcidr" {
  type = list(any)
}

variable "subnetcidr" {
  type = list(any)
}

variable "spnkvsecret" {
  type = string
}

variable "azure_region" {
  type = string
}

#  Resource Group Name
variable "resource_group" {
  type = string
}

# AKS Cluster name
variable "cluster_name" {
  type = string
}

#AKS DNS name
variable "dns_name" {
  type = string
}

variable "admin_username" {
  type = string
}

# Specify a valid kubernetes version
variable "kubernetes_version" {
  type = string
}

#AKS Agent pools
variable "agent_pools" {
  type = object({
    name            = string
    count           = number
    vm_size         = string
    os_disk_size_gb = string
    }
  )
}

#----------------------------VARIABLES API GATEWAY-------------------------------------

variable "publisher_name" {
  type        = string
  default     = "Mar"
  description = "publisher name"
}

variable "publisher_email" {
  type        = string
  default     = "company@terraform.io"
  description = "Publisher email"
}

variable "sku" {
  type        = string
  default     = "Developer_1"
  description = "SKU"
}

variable "revision" {
  type        = string
  default     = "1"
  description = "API revision"
}

variable "display_name" {
  type        = string
  default     = "Test API"
  description = "API display name"
}

variable "path" {
  type        = string
  default     = ""
  description = "Endpoint path"
}

variable "protocols" {
  type        = list(any)
  default     = ["https", "http"]
  description = "API security protocols"
}

variable "service_url" {
  type        = string
  default     = "http://conferenceapi.azurewebsites.net"
  description = "URL"
}