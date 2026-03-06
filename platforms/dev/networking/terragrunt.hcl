# platforms/dev/networking/terragrunt.hcl

# 1. Include the Root (Backend/Provider)
include "root" {
  path = find_in_parent_folders()
}

# 2. Include the EnvCommon (Module Source/Common Tags)
include "envcommon" {
  path   = "${get_terragrunt_dir()}/../../_envcommon/networking.hcl"
  expose = true # This allows us to access locals from envcommon
}

# 3. Environment Specific Inputs
inputs = {
  vpc_cidr    = "10.0.0.0/16"
  environment = "dev"
  region      = "us-east-1"
  
  # Merge common tags with environment specific tags
  tags = merge(
    include.envcommon.locals.common_tags,
    {
      Environment = "dev"
      Tier        = "Frontend"
    }
  )
}