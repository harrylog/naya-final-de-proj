# Root outputs.tf
# Define outputs that will be displayed after terraform apply

output "rds_endpoint" {
  description = "RDS instance endpoint for database connections"
  value       = module.mysql_database.db_endpoint
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.mysql_database.db_port
}

output "rds_identifier" {
  description = "RDS instance identifier"
  value       = module.mysql_database.db_identifier
}

output "parameter_group_name" {
  description = "Name of the created parameter group"
  value       = module.mysql_database.parameter_group_name
}

output "connection_string_example" {
  description = "Example connection string format (replace with actual values)"
  value       = "mysql://${var.master_username}:[PASSWORD]@${module.mysql_database.db_endpoint}:${module.mysql_database.db_port}/${var.db_name}"
  sensitive   = true
}

# ADD THIS TO outputs.tf

output "s3_bucket_name" {
  description = "Name of the data lake S3 bucket"
  value       = module.data_lake.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the data lake S3 bucket"
  value       = module.data_lake.bucket_arn
}

output "bronze_folders" {
  description = "Bronze layer folder structure"
  value       = module.data_lake.bronze_folders
}

output "silver_folders" {
  description = "Silver layer folder structure"  
  value       = module.data_lake.silver_folders
}

# ADD THIS TO outputs.tf

output "s3_policy_arn" {
  description = "ARN of the S3 data lake access policy"
  value       = module.iam_policies.s3_policy_arn
}

# ADD THIS TO outputs.tf

output "dms_replication_instance_arn" {
  description = "ARN of the DMS replication instance"
  value       = module.dms_migration.replication_instance_arn
}

output "dms_replication_instance_id" {
  description = "ID of the DMS replication instance"  
  value       = module.dms_migration.replication_instance_id
}

# ADD THIS TO outputs.tf

output "rds_secret_arn" {
  description = "ARN of the RDS credentials secret"
  value       = module.rds_secrets.secret_arn
}

output "rds_secret_name" {
  description = "Name of the RDS credentials secret"
  value       = module.rds_secrets.secret_name
}