# modules/dms/variables.tf
# Input variables for the DMS module

variable "dms_vpc_role_name" {
  description = "Name for the DMS VPC management role"
  type        = string
  default     = "dms-vpc-role"
}

variable "subnet_group_name" {
  description = "Name for the DMS subnet group"
  type        = string
  default     = "de-proj-dms-sub-group"
}

variable "replication_instance_id" {
  description = "Identifier for the DMS replication instance"
  type        = string
  default     = "de-proj-dms-replication-instance"
}

variable "instance_class" {
  description = "Instance class for the DMS replication instance"
  type        = string
  default     = "dms.t3.micro"
}

variable "allocated_storage" {
  description = "Storage allocated to the replication instance in GB"
  type        = number
  default     = 50
}

variable "publicly_accessible" {
  description = "Whether the replication instance should be publicly accessible"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags to apply to all DMS resources"
  type        = map(string)
  default     = {}
}

# ADD THESE TO modules/dms/variables.tf

variable "dms_logs_role_name" {
  description = "Name for the DMS CloudWatch logs role"
  type        = string
  default     = "dms-logs-role"
}

variable "source_endpoint_id" {
  description = "Identifier for the DMS source endpoint"
  type        = string
  default     = "de-proj-src-point"
}

# RDS connection details (passed from root)
variable "rds_endpoint" {
  description = "RDS endpoint hostname"
  type        = string
}

variable "rds_port" {
  description = "RDS port"
  type        = number
  default     = 3306
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

variable "rds_database_name" {
  description = "RDS database name"
  type        = string
}

# ADD THESE TO modules/dms/variables.tf

variable "dms_s3_role_name" {
  description = "Name for the DMS S3 access role"
  type        = string
  default     = "dms-s3-access-role"
}

variable "target_endpoint_id" {
  description = "Identifier for the DMS target endpoint"
  type        = string
  default     = "de-proj-target-point"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for target endpoint"
  type        = string
}