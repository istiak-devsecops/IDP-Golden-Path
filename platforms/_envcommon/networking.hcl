# platforms/_envcommon/networking.hcl
terraform {
  source = "../../../modules//networking" 
}

locals {
  # Common tags used by EVERY environment
  common_tags = {
    Project   = "IDPGoldenPath"
    ManagedBy = "Terragrunt"
  }
}

inputs = {
  environment = "dev"
  region      = "us-east-1"
}