variable "key_name" {
    type = string
}

variable "key_secret_manager_name" {
    type = string
}

variable "admin_role_arn" {
  type        = string
  description = "The ARN of the role that can manage this KMS key"
}