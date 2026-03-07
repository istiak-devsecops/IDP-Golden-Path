# Export the KMS Key ARN
output "kms_key_arn" {
  description = "The ARN of the KMS key for encryption"
  value       = aws_kms_key.idp_secrets_key.arn # 'this' must match your resource name
}

# Export the Secrets Manager Secret ARN
output "secret_arn" {
  description = "The ARN of the secret stored in Secrets Manager"
  value       = aws_secretsmanager_secret.idp_secrets_manager.arn
}