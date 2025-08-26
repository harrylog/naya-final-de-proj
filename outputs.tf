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