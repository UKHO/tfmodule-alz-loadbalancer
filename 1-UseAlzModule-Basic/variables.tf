
variable "rg_name" {
  description = "Resource group name for the load balancer"
  type        = string
}

variable "vnet_rg_name" {
  description = "Virtual network resource group name"
  type        = string
}

variable "vnet_name" {
  description = "Virtual network name"
  type        = string
}

variable "subnet_name" {
  description = "Subnet name for the load balancer"
  type        = string
}

# variable "law_name" {
#   description = "Log Analytics Workspace name"
#   type        = string
# }

# variable "law_rg_name" {
#   description = "Log Analytics Workspace resource group name"
#   type        = string
# }

variable "location" {
  description = "Azure region for the load balancer"
  type        = string
}

variable "lb_name" {
  description = "Name of the load balancer"
  type        = string
  default     = "app-ilb-prod"
}

variable "frontend_private_ip_allocation" {
  description = "Private IP allocation method for the load balancer frontend"
  type        = string
  default     = "Static"
}

variable "frontend_private_ip_address" {
  description = "Static private IP address for the load balancer frontend"
  type        = string
  default     = "10.20.3.10"
}

variable "backend_pool_name" {
  description = "Name for the backend address pool"
  type        = string
  default     = "beap"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
