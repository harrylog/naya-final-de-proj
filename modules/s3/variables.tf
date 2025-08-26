# modules/s3/variables.tf
# Input variables for the S3 data lake module

variable "bucket_name" {
  description = "Name of the S3 bucket for data lake storage"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name)) && length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "Bucket name must be 3-63 characters, start/end with letter/number, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "bronze_table_folders" {
  description = "List of table folders to create in bronze_data layer"
  type        = list(string)
  default     = ["customer", "product", "orders", "orderdetails"]
}

variable "silver_table_folders" {
  description = "List of table folders to create in silver_data layer"  
  type        = list(string)
  default     = ["customer", "product", "orders", "orderdetails"]
}

variable "common_tags" {
  description = "Common tags to apply to all S3 resources"
  type        = map(string)
  default     = {}
}