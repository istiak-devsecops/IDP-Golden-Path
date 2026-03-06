# platforms/dev/spoke/vpc/terragrunt.hcl
dependency "hub-vpc" {
  config_path = "../../hub/vpc"
}

# 1. Include the Root (Backend/Provider)
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# 2. Include the EnvCommon (Module Source/Common Tags)
include "envcommon" {
  path   = "${get_terragrunt_dir()}/../../_envcommon/networking.hcl"
  expose = true # This allows us to access locals from envcommon
}

# 3. Environment Specific Inputs
inputs = {
  hub_vpc_id  = dependency.hub-vpc.outputs.vpc_id
  hub_transit_gateway_id = dependency.hub-vpc.outputs.transit_gateway_id
  vpc_name        = "dev-spoke-app"
  cidr_block      = "10.1.0.0/16" # Must be different from Hub!
  public_subnets  = ["10.1.1.0/24"]
  private_subnets = ["10.1.2.0/24"]
  
  # Merge common tags with environment specific tags
  tags = merge(
    include.envcommon.locals.common_tags,
    {
      Environment = "dev"
      Tier        = "Frontend"
    }
  )
}

