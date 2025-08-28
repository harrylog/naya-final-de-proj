# modules/glue/variables.tf
# Input variables for the Glue module

variable "glue_role_name" {
  description = "Name of the IAM role for Glue"
  type        = string
  default     = "de-proj-glue-role"
}

variable "glue_database_name" {
  description = "Name of the Glue database"
  type        = string
  default     = "de-proj-glue-db"
}

variable "crawler_name" {
  description = "Name of the Glue crawler"
  type        = string
  default     = "de-proj-product-crawler"
}

variable "table_prefix" {
  description = "Prefix for crawler-created tables"
  type        = string
  default     = "raw_data_"
}

variable "etl_job_name" {
  description = "Name of the Glue ETL job"
  type        = string
  default     = "de-proj-product-etl-job"
}

variable "etl_script_name" {
  description = "Name of the ETL script file"
  type        = string
  default     = "raw_product_etl_job.py"
}

variable "etl_script_path" {
  description = "Local path to the ETL script"
  type        = string
  default     = "raw_product_etl_job.py"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "s3_policy_arn" {
  description = "ARN of the S3 access policy"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all Glue resources"
  type        = map(string)
  default     = {}
}

# ADD THIS TO modules/glue/variables.tf

variable "redshift_secret_arn" {
  description = "ARN of the Redshift credentials secret"
  type        = string
}