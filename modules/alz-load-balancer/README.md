# Azure Load Balancer Module

Enterprise-grade Azure Load Balancer module compliant with Azure Landing Zone standards.

## Features

- Internal and Public Load Balancer support
- Standard SKU (zone-redundant by default)
- Azure Monitor diagnostics integration
- Flexible probe and rule configuration
- Backend pool management
- Optional outbound rules
- Support for both static and dynamic IP allocation
- Configurable health probes and load balancing rules

## Requirements

- Terraform >= 1.5.0
- AzureRM Provider ~> 3.116

## Usage

### Internal Load Balancer (Basic)

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

### Public Load Balancer

```terraform
module "public_lb" {
  source = "git::https://github.com/UKHO/tfmodule-alz-loadbalancer.git//modules/alz-load-balancer?ref=v1.0.0"
  
  name                = "elb-prod"
  location            = "uksouth"
  resource_group_name = "rg-loadbalancer-prod"
  type                = "public"
  create_public_ip    = true
  backend_pool_name   = "backend-pool"

  probes = [
    {
      name                = "http-80"
      protocol            = "Http"
      port                = 80
      request_path        = "/health"
      interval            = 5
      unhealthy_threshold = 2
    }
  ]

  lb_rules = [
    {
      name                  = "http-80"
      protocol              = "Tcp"
      frontend_port         = 80
      backend_port          = 80
      probe_name            = "http-80"
      disable_outbound_snat = false
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

### Backend Pool Association

After creating the load balancer, associate VMs or NICs with the backend pool:

```terraform
resource "azurerm_network_interface_backend_address_pool_association" "vm01" {
  network_interface_id    = azurerm_network_interface.vm01.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = module.internal_lb.backend_address_pool_id
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Base name for the Load Balancer (used across child resources) | `string` | - | yes |
| location | Azure region for all resources | `string` | - | yes |
| resource_group_name | Resource group name | `string` | - | yes |
| type | Load balancer type: internal or public | `string` | `"internal"` | no |
| deployment_scope | Landing zone scope hint (hub/spoke/sandbox) | `string` | `"spoke"` | no |
| tags | Tags to apply to all resources | `map(string)` | `{}` | no |
| **Internal LB Settings** |
| subnet_id | Required for internal LBs: Subnet ID for the frontend private IP | `string` | `null` | yes (for internal) |
| frontend_private_ip_allocation | Private IP allocation for internal LB frontend (Static/Dynamic) | `string` | `"Static"` | no |
| frontend_private_ip_address | Optional static private IP for internal LB (if Static) | `string` | `null` | no |
| **Public LB Settings** |
| create_public_ip | If true and type == public, create a Standard Public IP | `bool` | `false` | no |
| public_ip_id | Existing Public IP ID for public LB (if not creating one) | `string` | `null` | no |
| public_ip_sku | Public IP SKU (Standard only) | `string` | `"Standard"` | no |
| public_ip_allocation_method | Public IP allocation method (Static for Standard) | `string` | `"Static"` | no |
| public_ip_sku_tier | Public IP SKU Tier (Regional or Global) | `string` | `"Regional"` | no |
| public_ip_zones | Availability zones for Public IP | `list(string)` | `["1", "2", "3"]` | no |
| **Backend Pool** |
| backend_pool_name | Name of the backend address pool | `string` | - | yes |
| **Probes** |
| probes | List of health probe configurations | `list(object)` | `[]` | no |
| **Load Balancing Rules** |
| lb_rules | List of load balancing rule configurations | `list(object)` | `[]` | no |
| **Outbound Rules** |
| enable_outbound_rule | Enable outbound rule (avoid when using NAT Gateway) | `bool` | `false` | no |
| outbound_protocol | Protocol for outbound rule | `string` | `"All"` | no |
| allocated_outbound_ports | Number of allocated outbound ports | `number` | `1024` | no |
| **Diagnostics** |
| enable_diagnostics | Enable Azure Monitor diagnostics | `bool` | `false` | no |
| log_analytics_workspace_id | Log Analytics Workspace ID for diagnostics | `string` | `null` | yes (if diagnostics enabled) |
| diagnostic_categories | List of diagnostic log categories to enable | `list(string)` | `null` | no |

### Probe Object Structure

```terraform
{
  name                = string  # Probe name
  protocol            = string  # Tcp, Http, or Https
  port                = number  # Port to probe
  request_path        = string  # (Optional) HTTP/HTTPS path
  interval            = number  # (Optional) Interval in seconds, default: 5
  unhealthy_threshold = number  # (Optional) Number of failures before unhealthy, default: 2
}
```

### LB Rule Object Structure

```terraform
{
  name                    = string  # Rule name
  protocol                = string  # Tcp or Udp
  frontend_port           = number  # Frontend port
  backend_port            = number  # Backend port
  probe_name              = string  # (Optional) Name of associated probe
  idle_timeout_in_minutes = number  # (Optional) Default: 4
  enable_floating_ip      = bool    # (Optional) Default: false
  disable_outbound_snat   = bool    # (Optional) Default: false
  load_distribution       = string  # (Optional) Default, SourceIP, SourceIPProtocol
}
```

## Outputs

| Name | Description |
|------|-------------|
| lb_id | Load Balancer resource ID |
| lb_frontend_ip_configuration_name | Frontend IP configuration name |
| backend_address_pool_id | Backend address pool ID for VM associations |
| public_ip_id | Public IP resource ID (if created) |
| private_frontend_ip | Private frontend IP address (for internal LBs) |

## Examples

See the [examples](../../) directory for complete working examples:
- `1-UseAlzModule-Basic/` - Basic internal load balancer configuration
- `2-UseAlzModule-Detailed/` - Detailed configuration with VM backend pool associations

## Azure Landing Zone Compliance

This module follows Azure Landing Zone best practices:

- **Standard SKU only** - Enforces Standard Load Balancer SKU for enterprise deployments
- **Zone redundancy** - Standard SKU provides zone redundancy by default
- **Diagnostics** - Optional integration with Log Analytics for monitoring
- **Tagging** - Supports consistent tagging across resources
- **Security** - Follows secure defaults (Static IPs, Standard SKU)
- **Validation** - Input validation on critical parameters

## Notes

- **Internal Load Balancers**: Require a `subnet_id` parameter
- **Public Load Balancers**: Can either create a new Public IP or use an existing one
- **Diagnostics**: When enabled, requires a `log_analytics_workspace_id`
- **Outbound Rules**: Avoid using when NAT Gateway is present in the subnet
- **Probes**: At least one probe is recommended for production workloads
- **Backend Associations**: Must be created separately using `azurerm_network_interface_backend_address_pool_association`

## License

Copyright © 2026 UK Hydrographic Office

## Support

For issues, questions, or contributions, please contact the UKHO platform team or open an issue in the repository.
