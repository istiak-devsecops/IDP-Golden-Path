

resource "aws_kms_key" "idp_secrets_key" {
  description             = "An example symmetric encryption KMS key"
  enable_key_rotation     = true
  deletion_window_in_days = 20

# THE KEY POLICY
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions" # Gives the account owner control
        Effect = "Allow"
        Principal = {
          AWS = "${var.admin_role_arn}"
        } # The ${data.aws_caller_identity.current.account_id}:root part ensures the "Account Owner" can always recover the key.
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Access for Key Administrators"
        Effect = "Allow"
        Principal = {
          AWS = "${var.admin_role_arn}" # We pass this from Terragrunt
        }
        Action = [
          "kms:Create*", "kms:Describe*", "kms:Enable*", 
          "kms:List*", "kms:Put*", "kms:Update*", 
          "kms:Revoke*", "kms:Disable*", "kms:Get*", 
          "kms:Delete*", "kms:TagResource", "kms:UntagResource", 
          "kms:ScheduleKeyDeletion", "kms:CancelKeyDeletion"
        ]
        Resource = "*"
      },
      {
        Sid = "AllowSpokeAccountUsage"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.spoke_account_id}:root" # This allows roles from spoke account to use the key
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*"
        ]
        Resource = "*"
      }
    ]
  })
  
}


resource "aws_kms_alias" "idp_secrets_key_alias" {
  name          = "${var.key_name}"
  target_key_id = aws_kms_key.idp_secrets_key.key_id
}

# Container
resource "aws_secretsmanager_secret" "idp_secrets_manager" {
  name = "${var.key_secret_manager_name}"
  kms_key_id = aws_kms_key.idp_secrets_key.key_id
}

# Secrets
resource "aws_secretsmanager_secret_version" "idp_secrets" {
  secret_id     = aws_secretsmanager_secret.idp_secrets_manager.id
  secret_string = "example-string-to-protect"
  lifecycle { 
    ignore_changes = [secret_string] 
    }
}