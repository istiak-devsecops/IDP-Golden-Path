include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules//secrets"
}

inputs = {
  key_name    = "alias/idp-secrets"
  key_secret_manager_name = "idp-golden-path-secret-manager"
  AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
}