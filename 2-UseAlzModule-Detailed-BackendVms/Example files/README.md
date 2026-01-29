The tf files provided in this example assume you have already created 2 virtual machines to use with the module.
The vm's in this example are referenced in the backend-vms.tf file.
The vm's are in a different resource group to the load balancer.

It is also possible to create the load balancer and vm's in the same group.  See the file backend-pool-association.tf.example , option B.
In this case - Option B- you would create the VM's at the same time as the load balancer and you would reference

resource "azurerm_network_interface_backend_address_pool_association" "yourvm1" {
  network_interface_id    = azurerm_network_interface.yourvm1_nic.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = module.internal_lb.backend_address_pool_id
}