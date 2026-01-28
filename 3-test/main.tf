terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}


module "internal_lb" {
  source              = "git::https://github.com/UKHO/tfmodule-alz-loadbalancer.git//modules/alz-load-balancer?ref=v1.0.0"
  name                = var.lb_name
  location            = data.azurerm_resource_group.app_rg.location
  resource_group_name = data.azurerm_resource_group.app_rg.name

  type                = "internal"
  subnet_id           = data.azurerm_subnet.app.id

  frontend_private_ip_allocation = var.frontend_private_ip_allocation
  frontend_private_ip_address    = var.frontend_private_ip_address
  
  backend_pool_name = var.backend_pool_name

  probes   = var.probes
  lb_rules = var.lb_rules

  enable_outbound_rule       = var.enable_outbound_rule
  enable_diagnostics         = var.enable_diagnostics
  log_analytics_workspace_id = var.log_analytics_workspace_id
  diagnostic_categories      = var.diagnostic_categories

  tags = var.tags
}
