# outputs.tf
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_endpoint
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.rds.db_port
}

output "database_name" {
  description = "Database name"
  value       = module.rds.db_name
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = module.s3.bucket_arn
}

output "iam_policy_arn" {
  description = "IAM policy ARN for S3 access"
  value       = module.iam.s3_policy_arn
}

output "secrets_manager_secret_arn" {
  description = "Secrets Manager secret ARN"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "mysql_workbench_connection_info" {
  description = "MySQL Workbench connection information"
  value = {
    hostname = module.rds.db_endpoint
    port     = module.rds.db_port
    username = "admin"
    password_secret = aws_secretsmanager_secret.db_credentials.name
  }
}