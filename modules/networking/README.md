# Networking Module (Hub-and-Spoke)

This module creates a standardized VNet/VPC with public and private subnets.
  - centralized network control using hub
  - secure internet access for spoke(private VPC) using TGW(transit gateway)
  - Ensured HA for VPC's

## Usage
```hcl
module "network" {
  source     = "../../modules/networking"
  cidr_block = "10.0.0.0/16"
  env        = "dev"
}
```