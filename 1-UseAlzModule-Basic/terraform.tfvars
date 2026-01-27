
rg_name      = "rg-sdstest-lb-prod"
vnet_rg_name = "m-spokeconfig-rg"
vnet_name    = "SDSvNetTest-vnet"
subnet_name  = "subnet2"
location = "uksouth"
backend_pool_name = "ilb-backendpool"
  

#law_name     = "law-platform"
#law_rg_name  = "rg-platform"

lb_name                        = "sdstest-ilb-prod"
frontend_private_ip_allocation = "Static"
frontend_private_ip_address    = "10.241.11.150"

tags = {
  owner      = "steve.aston"
  env        = "prod"
  costCenter = "IT-PLAT"
  service    = "webapp"
}
