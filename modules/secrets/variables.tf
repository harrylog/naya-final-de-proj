# modules/secrets/variables.tf
# Input variables for the Secrets Manager module

variable "secret_name" {
  description = "Name of the secret in AWS Secrets Manager"
  type        = string
  default     = "de-proj-rds-secret"
}

variable "rds_hostname" {
  description = "RDS instance hostname"
  type        = string
}

variable "rds_username" {
  description = "RDS master username"
  type        = string
}

variable "rds_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "rds_dbname" {
  description = "RDS database name"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all secrets resources"
  type        = map(string)
  default     = {}
}