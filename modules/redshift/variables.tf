# modules/redshift/variables.tf
# Input variables for the Redshift module

variable "redshift_role_name" {
  description = "Name of the IAM role for Redshift"
  type        = string
  default     = "de-proj-redshift-role"
}

variable "workgroup_name" {
  description = "Name of the Redshift serverless workgroup"
  type        = string
  default     = "de-proj-redshift-workgroup"
}

variable "namespace_name" {
  description = "Name of the Redshift serverless namespace"
  type        = string
  default     = "de-proj-redshift-ns"
}

variable "database_name" {
  description = "Name of the default database"
  type        = string
  default     = "dev"
}

variable "admin_username" {
  description = "Admin username for Redshift"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Admin password for Redshift"
  type        = string
  sensitive   = true
}

variable "base_capacity" {
  description = "Base capacity for the workgroup in RPUs"
  type        = number
  default     = 8
}

variable "publicly_accessible" {
  description = "Whether the workgroup should be publicly accessible"
  type        = bool
  default     = true
}

variable "redshift_secret_name" {
  description = "Name of the Redshift credentials secret"
  type        = string
  default     = "de-proj-redshift-secret-v2"  # New name
}

variable "s3_policy_arn" {
  description = "ARN of the S3 access policy"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all Redshift resources"
  type        = map(string)
  default     = {}
}

