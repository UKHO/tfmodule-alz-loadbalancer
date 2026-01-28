# How to Use This Azure Load Balancer Module

This guide will walk you through using the Azure Load Balancer module step-by-step, from initial setup to deployment.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start (5 Minutes)](#quick-start-5-minutes)
- [Step-by-Step Guide](#step-by-step-guide)
- [Common Scenarios](#common-scenarios)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before you begin, ensure you have:

1. **Terraform installed** (>= 1.5.0)
   ```powershell
   terraform version
   ```

2. **Azure CLI installed and authenticated**
   ```powershell
   az login
   az account show
   ```

3. **Existing Azure resources:**
   - Resource Group (where the load balancer will be deployed)
   - Virtual Network (VNet)
   - Subnet (where the load balancer frontend IP will be placed)
   - Backend VMs or NICs (optional, can be added later)

4. **Permissions:**
   - Contributor or Owner role on the resource group
   - Network Contributor role on the VNet/subnet

---

## Quick Start (5 Minutes)

### 1. Create Your Project Directory

```powershell
# Create a new directory for your Terraform configuration
mkdir my-loadbalancer
cd my-loadbalancer
```

### 2. Create `main.tf`

Create a file called `main.tf` with the following content:

```terraform
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

# Look up your existing resource group
data "azurerm_resource_group" "rg" {
  name = var.rg_name
}

# Look up your existing VNet and subnet
data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.vnet_rg_name
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_rg_name
}

# Deploy the load balancer module
module "load_balancer" {
  source = "git::https://github.com/UKHO/tfmodule-alz-loadbalancer.git//modules/alz-load-balancer?ref=v1.0.0"
  
  name                = var.lb_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name
  
  type      = "internal"
  subnet_id = data.azurerm_subnet.subnet.id
  
  frontend_private_ip_allocation = var.frontend_private_ip_allocation
  frontend_private_ip_address    = var.frontend_private_ip_address
  backend_pool_name              = var.backend_pool_name

  probes = [
    {
      name                = "tcp-443"
      protocol            = "Tcp"
      port                = 443
      interval            = 5
      unhealthy_threshold = 2
    }
  ]

  lb_rules = [
    {
      name                  = "https-443"
      protocol              = "Tcp"
      frontend_port         = 443
      backend_port          = 443
      probe_name            = "tcp-443"
      disable_outbound_snat = true
    }
  ]

  enable_diagnostics         = false
  
  tags = var.tags
}

# Output the important information
output "load_balancer_id" {
  value = module.load_balancer.lb_id
}

output "backend_pool_id" {
  value = module.load_balancer.backend_address_pool_id
}

output "frontend_ip" {
  value = module.load_balancer.private_frontend_ip
}
```

### 3. Create `variables.tf`

```terraform
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
  description = "IP allocation method (Static or Dynamic)"
  type        = string
  default     = "Static"
}

variable "frontend_private_ip_address" {
  description = "Static private IP address"
  type        = string
}

variable "backend_pool_name" {
  description = "Backend pool name"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
}
```

### 4. Create `terraform.tfvars`

Create a file with your actual values:

```terraform
rg_name      = "rg-myapp-prod"
vnet_rg_name = "rg-network"
vnet_name    = "vnet-spoke-prod"
subnet_name  = "subnet-backend"
location     = "uksouth"

lb_name                        = "ilb-myapp-prod"
frontend_private_ip_allocation = "Static"
frontend_private_ip_address    = "10.1.2.100"  # Use an available IP in your subnet
backend_pool_name              = "myapp-backend"

tags = {
  owner      = "platform-team"
  env        = "prod"
  costCenter = "IT"
  service    = "myapp"
}
```

### 5. Deploy

```powershell
# Initialize Terraform
terraform init

# Preview the changes
terraform plan

# Deploy the load balancer
terraform apply
```

**That's it!** Your load balancer is now deployed. 🎉

---

## Step-by-Step Guide

### Step 1: Gather Your Azure Resource Information

Before starting, collect this information:

```powershell
# List your resource groups
az group list --output table

# List VNets in a resource group
az network vnet list --resource-group "rg-network" --output table

# List subnets in a VNet
az network vnet subnet list --resource-group "rg-network" --vnet-name "vnet-spoke" --output table

# Show subnet details including address prefix
az network vnet subnet show --resource-group "rg-network" --vnet-name "vnet-spoke" --name "subnet-backend"
```

**Important:** Choose a private IP address that:
- Is within your subnet's address range
- Is NOT already in use
- Is NOT one of the first 4 IPs (Azure reserves these)

### Step 2: Choose Your Module Version

Always use a specific version tag for production:

```terraform
# Recommended: Use a specific version
source = "git::https://github.com/UKHO/tfmodule-alz-loadbalancer.git//modules/alz-load-balancer?ref=v1.0.0"

# Alternative: Use the latest from main (not recommended for production)
source = "git::https://github.com/UKHO/tfmodule-alz-loadbalancer.git//modules/alz-load-balancer?ref=main"
```

### Step 3: Configure Your Load Balancer

Copy one of the example configurations from this repository:

```powershell
# Option 1: Use the Basic example
cd 1-UseAlzModule-Basic
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Option 2: Use the Detailed example (includes backend pool associations)
cd 2-UseAlzModule-Detailed
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### Step 4: Initialize and Plan

```powershell
# Download provider plugins and the module
terraform init

# Validate your configuration
terraform validate

# Preview what will be created
terraform plan
```

Review the plan output carefully. It should show:
- 1 Load Balancer to be created
- 1 Backend Address Pool
- Health probes (based on your configuration)
- Load balancing rules (based on your configuration)

### Step 5: Deploy

```powershell
# Deploy the load balancer
terraform apply

# Review the output and type 'yes' to confirm
```

### Step 6: Add Backend VMs to the Pool

After the load balancer is created, associate your VMs:

```terraform
# If you have existing VMs, add this to your configuration:
data "azurerm_network_interface" "vm01" {
  name                = "vm01-nic"
  resource_group_name = "rg-vms"
}

resource "azurerm_network_interface_backend_address_pool_association" "vm01" {
  network_interface_id    = data.azurerm_network_interface.vm01.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = module.load_balancer.backend_address_pool_id
}
```

Then apply the changes:
```powershell
terraform apply
```

### Step 7: Verify the Deployment

```powershell
# Check the load balancer status
az network lb show --resource-group "rg-myapp-prod" --name "ilb-myapp-prod" --output table

# Check backend pool health
az network lb show --resource-group "rg-myapp-prod" --name "ilb-myapp-prod" --query "backendAddressPools[0]"

# Test connectivity (from a VM in the same VNet)
# Replace with your load balancer IP
Test-NetConnection -ComputerName 10.1.2.100 -Port 443
```

---

## Common Scenarios

### Scenario 1: Internal Load Balancer for Web Application

**Use Case:** Distribute HTTPS traffic across multiple web servers

```terraform
module "web_lb" {
  source = "git::https://github.com/UKHO/tfmodule-alz-loadbalancer.git//modules/alz-load-balancer?ref=v1.0.0"
  
  name                = "ilb-web-prod"
  location            = "uksouth"
  resource_group_name = "rg-web-prod"
  type                = "internal"
  subnet_id           = data.azurerm_subnet.web.id
  
  frontend_private_ip_allocation = "Static"
  frontend_private_ip_address    = "10.1.2.100"
  backend_pool_name              = "web-servers"

  probes = [
    {
      name                = "https-health"
      protocol            = "Https"
      port                = 443
      request_path        = "/health"
      interval            = 5
      unhealthy_threshold = 2
    }
  ]

  lb_rules = [
    {
      name                  = "https"
      protocol              = "Tcp"
      frontend_port         = 443
      backend_port          = 443
      probe_name            = "https-health"
      disable_outbound_snat = true
    }
  ]

  enable_diagnostics         = true
  log_analytics_workspace_id = "/subscriptions/.../workspaces/law-platform"

  tags = {
    environment = "production"
    service     = "web"
  }
}
```

### Scenario 2: Load Balancer for Multiple Ports

**Use Case:** Web application with both HTTP (80) and HTTPS (443)

```terraform
probes = [
  {
    name                = "http-80"
    protocol            = "Http"
    port                = 80
    request_path        = "/health"
  },
  {
    name                = "https-443"
    protocol            = "Https"
    port                = 443
    request_path        = "/health"
  }
]

lb_rules = [
  {
    name                  = "http"
    protocol              = "Tcp"
    frontend_port         = 80
    backend_port          = 80
    probe_name            = "http-80"
    disable_outbound_snat = true
  },
  {
    name                  = "https"
    protocol              = "Tcp"
    frontend_port         = 443
    backend_port          = 443
    probe_name            = "https-443"
    disable_outbound_snat = true
  }
]
```

### Scenario 3: SQL Server AlwaysOn Load Balancer

**Use Case:** SQL Server high availability setup

```terraform
module "sql_lb" {
  source = "git::https://github.com/UKHO/tfmodule-alz-loadbalancer.git//modules/alz-load-balancer?ref=v1.0.0"
  
  name                = "ilb-sql-prod"
  location            = "uksouth"
  resource_group_name = "rg-sql-prod"
  type                = "internal"
  subnet_id           = data.azurerm_subnet.sql.id
  
  frontend_private_ip_allocation = "Static"
  frontend_private_ip_address    = "10.1.3.100"
  backend_pool_name              = "sql-servers"

  probes = [
    {
      name                = "sql-probe"
      protocol            = "Tcp"
      port                = 59999  # SQL AlwaysOn probe port
      interval            = 5
      unhealthy_threshold = 2
    }
  ]

  lb_rules = [
    {
      name                    = "sql-1433"
      protocol                = "Tcp"
      frontend_port           = 1433
      backend_port            = 1433
      probe_name              = "sql-probe"
      enable_floating_ip      = true   # REQUIRED for SQL AlwaysOn
      idle_timeout_in_minutes = 30
      disable_outbound_snat   = true
    }
  ]

  tags = {
    environment = "production"
    service     = "sql"
  }
}
```

### Scenario 4: Public Load Balancer (DMZ/Internet-Facing)

**Use Case:** Internet-facing application in hub network

```terraform
module "public_lb" {
  source = "git::https://github.com/UKHO/tfmodule-alz-loadbalancer.git//modules/alz-load-balancer?ref=v1.0.0"
  
  name                = "elb-dmz-prod"
  location            = "uksouth"
  resource_group_name = "rg-dmz-prod"
  type                = "public"
  create_public_ip    = true
  backend_pool_name   = "dmz-servers"
  
  deployment_scope = "hub"

  probes = [
    {
      name         = "http-health"
      protocol     = "Http"
      port         = 80
      request_path = "/"
    }
  ]

  lb_rules = [
    {
      name                  = "http"
      protocol              = "Tcp"
      frontend_port         = 80
      backend_port          = 80
      probe_name            = "http-health"
      disable_outbound_snat = false
    },
    {
      name                  = "https"
      protocol              = "Tcp"
      frontend_port         = 443
      backend_port          = 443
      probe_name            = "http-health"
      disable_outbound_snat = false
    }
  ]

  enable_diagnostics         = true
  log_analytics_workspace_id = "/subscriptions/.../workspaces/law-platform"

  tags = {
    environment = "production"
    service     = "public-web"
  }
}
```

---

## Troubleshooting

### Issue: "Subnet not found"

**Solution:** Verify the subnet exists and you have the correct names:
```powershell
az network vnet subnet show --resource-group "rg-network" --vnet-name "vnet-spoke" --name "subnet-backend"
```

### Issue: "IP address already in use"

**Solution:** Choose a different IP address or check what's using it:
```powershell
# List all private IP addresses in use in your subnet
az network nic list --query "[?ipConfigurations[?subnet.id.contains(@, 'subnet-backend')]].{Name:name, IP:ipConfigurations[0].privateIPAddress}" --output table
```

### Issue: Backend pool shows as unhealthy

**Common causes:**
1. **VM not associated with backend pool** - Add the association resource
2. **Health probe port not open** - Check NSG rules and VM firewall
3. **Application not responding** - Verify the application is running on backend VMs
4. **Wrong probe configuration** - Verify protocol, port, and path

**Check health:**
```powershell
az network lb show --resource-group "rg-myapp-prod" --name "ilb-myapp-prod" --query "backendAddressPools[0].backendIPConfigurations[*].id"
```

### Issue: "Module not found" error

**Solution:** Make sure you've run `terraform init`:
```powershell
terraform init -upgrade
```

### Issue: Can't connect through the load balancer

**Checklist:**
1. ✅ Backend VMs are associated with the pool
2. ✅ Health probes are showing as healthy
3. ✅ NSG allows traffic on the frontend port
4. ✅ NSG allows traffic on the backend port
5. ✅ Application is listening on the backend port
6. ✅ You're connecting from within the VNet (for internal LB)

---

## Next Steps

After successfully deploying your load balancer:

1. **Set up monitoring** - Enable diagnostics and create alerts
2. **Configure DNS** - Add a DNS record pointing to the LB IP
3. **Test failover** - Stop one backend VM and verify traffic shifts
4. **Document** - Record your configuration for team reference
5. **Backup state** - Use remote state storage (Azure Storage Account)

---

## Additional Resources

- [Module Documentation](modules/alz-load-balancer/README.md)
- [Example Configurations](1-UseAlzModule-Basic/)
- [Azure Load Balancer Documentation](https://learn.microsoft.com/en-us/azure/load-balancer/)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

---

## Getting Help

If you encounter issues:
1. Check the [Troubleshooting](#troubleshooting) section
2. Review the [examples](1-UseAlzModule-Basic/) in this repository
3. Open an issue in the repository
4. Contact the UKHO Platform Team

---

**Good luck with your deployment!** 🚀
