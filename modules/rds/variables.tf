# modules/rds/variables.tf
# Input variables for the RDS module
# These make the module reusable and configurable

variable "db_identifier" {
  description = "Unique identifier for the RDS instance"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.db_identifier))
    error_message = "DB identifier must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "db_name" {
  description = "Name of the initial database to create"
  type        = string
  default     = null
  
  validation {
    condition     = var.db_name == null || can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_name))
    error_message = "Database name must start with a letter and contain only letters, numbers, and underscores."
  }
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
  
  validation {
    condition     = length(var.master_username) >= 1 && length(var.master_username) <= 16
    error_message = "Master username must be between 1 and 16 characters."
  }
}

variable "master_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.master_password) >= 8
    error_message = "Master password must be at least 8 characters long."
  }
}

variable "parameter_group_name" {
  description = "Name for the DB parameter group"
  type        = string
}

variable "parameter_group_description" {
  description = "Description for the DB parameter group"
  type        = string
  default     = "Custom parameter group for MySQL"
}

variable "common_tags" {
  description = "Common tags to apply to all resources in this module"
  type        = map(string)
  default     = {}
}