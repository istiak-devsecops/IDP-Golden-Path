# platforms/_envcommon/networking.hcl
terraform {
  source = "../../../modules//networking" 
}

locals {
  # Common tags used by EVERY environment
  common_tags = {
    Project   = "MyCloudProject"
    ManagedBy = "Terragrunt"
  }
}