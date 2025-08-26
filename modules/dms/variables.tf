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