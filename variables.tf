# Root variables.tf
# Define all input variables for the root configuration

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "db_identifier" {
  description = "Unique identifier for the RDS instance"
  type        = string
  default     = "naya-de-proj-mysql-db"
}

variable "db_name" {
  description = "Name of the initial database to create"
  type        = string
  default     = "naya_de_db"
}

variable "master_username" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "admin"
}

variable "master_password" {
  description = "Master password for the RDS instance"
  type        = string
  default     = "naya-de-proj-pwd-mysql8"
  sensitive   = true  # This marks the variable as sensitive in logs
}

variable "parameter_group_name" {
  description = "Name for the DB parameter group"
  type        = string
  default     = "naya-de-proj-db-pg"
}

variable "parameter_group_description" {
  description = "Description for the DB parameter group"
  type        = string
  default     = "Parameter group for MySQL configuration"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "naya-data-engineering"
    Environment = "development"
    Owner       = "naya-learning"
  }
}


# ADD THIS TO variables.tf

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for data lake storage"
  type        = string
  default     = "naya-de-rds-cdc-s3"
}