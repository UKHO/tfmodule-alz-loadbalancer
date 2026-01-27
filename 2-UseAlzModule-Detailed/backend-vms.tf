# Add to your 2UseAlzModule/main.tf or create backend-vms.tf
#This is optional 

data "azurerm_network_interface" "vm01" {
  name                = "vm01-nic"
  resource_group_name = "rg-backend-vms"
}

resource "azurerm_network_interface_backend_address_pool_association" "vm01" {
  network_interface_id    = data.azurerm_network_interface.vm01.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = module.internal_lb.backend_address_pool_id
}

data "azurerm_network_interface" "vm02" {
  name                = "vm02-nic"
  resource_group_name = "rg-backend-vms"
}

resource "azurerm_network_interface_backend_address_pool_association" "vm02" {
  network_interface_id    = data.azurerm_network_interface.vm02.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = module.internal_lb.backend_address_pool_id
}