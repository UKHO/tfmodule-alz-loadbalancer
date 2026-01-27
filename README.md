# Azure Load Balancer Terraform Module

Enterprise-grade Terraform module for deploying Azure Load Balancers compliant with Azure Landing Zone standards.

## Repository Structure

```
.
├── modules/
│   └── alz-load-balancer/       # Main reusable module
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── versions.tf
│       └── README.md            # Module documentation
├── 1-UseAlzModule-Basic/        # Basic usage example
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars
│   ├── data.tf
│   └── *.example files
└── 2-UseAlzModule-Detailed/     # Detailed usage with backend pool associations
    ├── main.tf
    ├── variables.tf
    ├── terraform.tfvars
    └── backend-vms.tf
```

## Quick Start

### Using the Module in Your Project

Reference the module from your Terraform configuration:

```terraform
module "internal_lb" {
  source = "git::https://github.com/UKHO/tfmodule-alz-loadbalancer.git//modules/alz-load-balancer?ref=v1.0.0"
  
  name                = "ilb-prod"
  location            = "uksouth"
  resource_group_name = "rg-loadbalancer-prod"
  type                = "internal"
  subnet_id           = "/subscriptions/.../subnets/backend-subnet"
  
  frontend_private_ip_allocation = "Static"
  frontend_private_ip_address    = "10.0.1.100"
  backend_pool_name              = "backend-pool"

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

  enable_diagnostics         = true
  log_analytics_workspace_id = "/subscriptions/.../workspaces/law-platform"

  tags = {
    environment = "production"
    owner       = "platform-team"
  }
}
```

### Running the Examples

#### Example 1: Basic Configuration

```bash
cd 1-UseAlzModule-Basic
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

#### Example 2: Detailed Configuration with Backend Pools

```bash
cd 2-UseAlzModule-Detailed
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

## Features

- ✅ **Internal and Public Load Balancers** - Support for both deployment types
- ✅ **Standard SKU** - Enterprise-grade with zone redundancy
- ✅ **Health Probes** - Configurable TCP, HTTP, and HTTPS probes
- ✅ **Load Balancing Rules** - Flexible rule configuration
- ✅ **Backend Pool Management** - Easy association with VMs and NICs
- ✅ **Azure Monitor Integration** - Optional diagnostics and logging
- ✅ **Outbound Rules** - Optional outbound connectivity configuration
- ✅ **Tagging Support** - Consistent resource tagging
- ✅ **Input Validation** - Built-in validation for critical parameters

## Module Reference Options

### Using a Specific Version (Recommended for Production)

```terraform
source = "git::https://github.com/UKHO/tfmodule-alz-loadbalancer.git//modules/alz-load-balancer?ref=v1.0.0"
```

### Using the Latest from Main Branch

```terraform
source = "git::https://github.com/UKHO/tfmodule-alz-loadbalancer.git//modules/alz-load-balancer?ref=main"
```

### Using SSH (for Private Repositories)

```terraform
source = "git::ssh://git@github.com/UKHO/tfmodule-alz-loadbalancer.git//modules/alz-load-balancer?ref=v1.0.0"
```

## Requirements

- **Terraform**: >= 1.5.0
- **Azure Provider**: ~> 3.116
- **Azure Subscription**: With appropriate permissions to create load balancers and related resources

## Documentation

- [Module Documentation](modules/alz-load-balancer/README.md) - Detailed module inputs, outputs, and usage
- [Example 1 - Basic](1-UseAlzModule-Basic/) - Simple internal load balancer
- [Example 2 - Detailed](2-UseAlzModule-Detailed/) - Advanced configuration with backend pool associations

## Use Cases

### Internal Load Balancer for Web Tier

Deploy an internal load balancer for distributing traffic across web servers in a spoke network:

```terraform
module "web_tier_lb" {
  source = "git::https://github.com/UKHO/tfmodule-alz-loadbalancer.git//modules/alz-load-balancer?ref=v1.0.0"
  
  name                = "ilb-web-prod"
  type                = "internal"
  location            = "uksouth"
  resource_group_name = "rg-web-prod"
  subnet_id           = data.azurerm_subnet.web.id
  backend_pool_name   = "web-servers"
  
  frontend_private_ip_allocation = "Static"
  frontend_private_ip_address    = "10.1.2.100"

  probes = [
    { name = "https", protocol = "Https", port = 443, request_path = "/health" }
  ]

  lb_rules = [
    { name = "https", protocol = "Tcp", frontend_port = 443, backend_port = 443, probe_name = "https" }
  ]

  enable_diagnostics         = true
  log_analytics_workspace_id = var.law_id

  tags = var.common_tags
}
```

### Public Load Balancer for DMZ

Deploy a public-facing load balancer in a hub network:

```terraform
module "dmz_lb" {
  source = "git::https://github.com/UKHO/tfmodule-alz-loadbalancer.git//modules/alz-load-balancer?ref=v1.0.0"
  
  name                = "elb-dmz-prod"
  type                = "public"
  location            = "uksouth"
  resource_group_name = "rg-dmz-prod"
  create_public_ip    = true
  backend_pool_name   = "dmz-servers"
  
  deployment_scope = "hub"

  probes = [
    { name = "http", protocol = "Http", port = 80, request_path = "/" }
  ]

  lb_rules = [
    { name = "http", protocol = "Tcp", frontend_port = 80, backend_port = 80, probe_name = "http" },
    { name = "https", protocol = "Tcp", frontend_port = 443, backend_port = 443, probe_name = "http" }
  ]

  enable_diagnostics         = true
  log_analytics_workspace_id = var.law_id

  tags = var.common_tags
}
```

## Azure Landing Zone Compliance

This module adheres to Azure Landing Zone principles:

- **Standard SKU Enforcement** - Only Standard Load Balancer SKU is allowed
- **Zone Redundancy** - Standard SKU provides built-in zone redundancy
- **Monitoring & Diagnostics** - Integration with Log Analytics
- **Network Segmentation** - Supports hub and spoke topologies
- **Resource Tagging** - Consistent tagging for governance
- **Security Best Practices** - Secure defaults and input validation

## Contributing

To contribute to this module:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with the example configurations
5. Submit a pull request

## Versioning

This project uses semantic versioning. For available versions, see the [tags on this repository](https://github.com/UKHO/tfmodule-alz-loadbalancer/tags).

## Authors

UK Hydrographic Office - Platform Team

## License

Copyright © 2026 UK Hydrographic Office

## Support

For issues, questions, or feature requests:
- Open an issue in this repository
- Contact the UKHO Platform Team

## Related Resources

- [Azure Load Balancer Documentation](https://learn.microsoft.com/en-us/azure/load-balancer/)
- [Azure Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
