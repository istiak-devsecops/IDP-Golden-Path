# Remote State Module

This module creates a standardized remote state for the state file.
    - versioning(enabled)
    - server side encryption(envelop encryption)
    - state locking(enabled)
    - public access(blocked)

## Usage
```hcl
module "remoteState" {
  source     = "../../modules/remote-state"
  storage_name = "idpGoldenPath001"
  env        = "dev"
}
```