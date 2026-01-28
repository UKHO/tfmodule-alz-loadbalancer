
rg_name      = "rg-loadbalancer-prod"
vnet_rg_name = "rg-network"
vnet_name    = "vnet-spoke"
subnet_name  = "subnet-backend"
location = "uksouth"
backend_pool_name = "ilb-backendpool"
  

#law_name     = "law-platform"
#law_rg_name  = "rg-platform"

lb_name                        = "ilb-prod"
frontend_private_ip_allocation = "Static"
frontend_private_ip_address    = "10.0.1.100"

tags = {
  owner      = "team-name"
  env        = "prod"
  costCenter = "cost-center"
  service    = "application"
}
