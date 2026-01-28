
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

variable "location" {
  description = "Azure region for the load balancer"
  type        = string
}

variable "lb_name" {
  description = "Name of the load balancer"
  type        = string
}

variable "frontend_private_ip_allocation" {
  description = "Private IP allocation method for the load balancer frontend"
  type        = string
  default     = "Static"
}

variable "frontend_private_ip_address" {
  description = "Static private IP address for the load balancer frontend"
  type        = string
}

variable "backend_pool_name" {
  description = "Name for the backend address pool"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "probes" {
  description = "List of health probe configurations"
  type = list(object({
    name                = string
    protocol            = string
    port                = number
    request_path        = optional(string)
    interval            = optional(number)
    unhealthy_threshold = optional(number)
  }))
  default = [
    {
      name                = "tcp-443"
      protocol            = "Tcp"
      port                = 443
      interval            = 5
      unhealthy_threshold = 2
    }
  ]
}

variable "lb_rules" {
  description = "List of load balancing rule configurations"
  type = list(object({
    name                    = string
    protocol                = string
    frontend_port           = number
    backend_port            = number
    probe_name              = optional(string)
    disable_outbound_snat   = optional(bool)
    enable_floating_ip      = optional(bool)
    idle_timeout_in_minutes = optional(number)
    load_distribution       = optional(string)
  }))
  default = [
    {
      name                  = "https-443"
      protocol              = "Tcp"
      frontend_port         = 443
      backend_port          = 443
      probe_name            = "tcp-443"
      disable_outbound_snat = true
    }
  ]
}

variable "enable_outbound_rule" {
  description = "Enable outbound rule (avoid when using NAT Gateway)"
  type        = bool
  default     = false
}

variable "enable_diagnostics" {
  description = "Enable Azure Monitor diagnostics"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostics"
  type        = string
  default     = null
}

variable "diagnostic_categories" {
  description = "List of diagnostic log categories to enable (null to auto-discover all)"
  type        = list(string)
  default     = null
}
