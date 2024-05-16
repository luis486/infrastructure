variable "secret_names" {
  description = "Names of the Azure Key Vault secrets"
  type        = list(string)
}

variable "secret_values" {
  description = "Values of the Azure Key Vault secrets"
  type        = list(string)
}

variable "key_names" {
  description = "Names of the Azure Key Vault keys"
  type        = list(string)
}

variable "key_types" {
  description = "Types of the Azure Key Vault keys"
  type        = list(string)
}

variable "key_sizes" {
  description = "Sizes of the Azure Key Vault keys"
  type        = list(number)
}

variable "key_opts" {
  description = "Key options"
  type        = list(string)
}