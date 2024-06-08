variable "application_gateway_name" {
  description = "The name of the Application Gateway."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The location of the resource group."
  type        = string
}

variable "sku_name" {
  description = "The SKU name of the Application Gateway."
  type        = string
}

variable "sku_tier" {
  description = "The SKU tier of the Application Gateway."
  type        = string
}

variable "sku_capacity" {
  description = "The capacity of the Application Gateway."
  type        = number
}

variable "gateway_ip_configuration_name" {
  description = "The name of the gateway IP configuration."
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet."
  type        = string
}

variable "frontend_ip_configuration_name" {
  description = "The name of the frontend IP configuration."
  type        = string
}

variable "public_ip_address_id" {
  description = "The ID of the public IP address."
  type        = string
}

variable "frontend_port_name" {
  description = "The name of the frontend port."
  type        = string
}

variable "frontend_port_port" {
  description = "The port number for the frontend port."
  type        = number
}

variable "backend_address_pool_name" {
  description = "The name of the backend address pool."
  type        = string
}

variable "backend_http_settings_name" {
  description = "The name of the backend HTTP settings."
  type        = string
}

variable "cookie_based_affinity" {
  description = "Cookie-based affinity setting for the backend HTTP settings."
  type        = string
}

variable "backend_http_settings_port" {
  description = "The port number for the backend HTTP settings."
  type        = number
}

variable "backend_http_settings_protocol" {
  description = "The protocol for the backend HTTP settings."
  type        = string
}

variable "backend_http_settings_request_timeout" {
  description = "The request timeout for the backend HTTP settings."
  type        = number
}

variable "http_listener_name" {
  description = "The name of the HTTP listener."
  type        = string
}

variable "http_listener_frontend_ip_configuration_name" {
  description = "The name of the frontend IP configuration for the HTTP listener."
  type        = string
}

variable "http_listener_frontend_port_name" {
  description = "The name of the frontend port for the HTTP listener."
  type        = string
}

variable "http_listener_protocol" {
  description = "The protocol for the HTTP listener."
  type        = string
}

variable "request_routing_rule_name" {
  description = "The name of the request routing rule."
  type        = string
}

variable "request_routing_rule_rule_type" {
  description = "The rule type for the request routing rule."
  type        = string
}

variable "request_routing_rule_priority" {
  description = "The priority for the request routing rule."
  type        = number
}

variable "request_routing_rule_http_listener_name" {
  description = "The name of the HTTP listener for the request routing rule."
  type        = string
}

variable "request_routing_rule_backend_address_pool_name" {
  description = "The name of the backend address pool for the request routing rule."
  type        = string
}

variable "request_routing_rule_backend_http_settings_name" {
  description = "The name of the backend HTTP settings for the request routing rule."
  type        = string
}
