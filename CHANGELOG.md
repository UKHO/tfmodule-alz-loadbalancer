# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive README documentation for the module
- Root README with quick start guide and examples
- .gitignore file for Terraform projects
- CHANGELOG.md for version tracking

### Changed
- Removed provider block from module versions.tf (breaking change - modules should not declare providers)

### Fixed
- Module now properly follows Terraform best practices for reusable modules

## [1.0.0] - 2026-01-27

### Added
- Initial release of Azure Load Balancer module
- Support for Internal Load Balancers
- Support for Public Load Balancers
- Standard SKU enforcement for enterprise compliance
- Health probe configuration (TCP, HTTP, HTTPS)
- Load balancing rule configuration
- Optional outbound rule support
- Azure Monitor diagnostics integration
- Backend address pool management
- Comprehensive variable validation
- Example configurations (Basic and Detailed)
- Support for zone-redundant deployments
- Tagging support for governance
- Log Analytics workspace integration
- Public IP creation and management
- Static and Dynamic IP allocation options

### Security
- Enforced Standard SKU for enhanced security
- Input validation on critical parameters
- Secure defaults for all configurations

---

## Release Notes

### Version 1.0.0 - Initial Release

This is the first production-ready release of the UKHO Azure Load Balancer Terraform module. The module has been designed to be compliant with Azure Landing Zone standards and follows enterprise best practices.

**Key Features:**
- Enterprise-grade load balancing for Azure workloads
- Support for both internal and public load balancers
- Full integration with Azure Monitor for diagnostics
- Flexible health probe and rule configuration
- Zone redundancy by default with Standard SKU

**Breaking Changes:**
- None (initial release)

**Known Issues:**
- None

**Upgrade Notes:**
- This is the initial release

---

## How to Use This Changelog

- **Added** for new features
- **Changed** for changes in existing functionality
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** for vulnerability fixes

[Unreleased]: https://github.com/UKHO/tfmodule-alz-loadbalancer/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/UKHO/tfmodule-alz-loadbalancer/releases/tag/v1.0.0
