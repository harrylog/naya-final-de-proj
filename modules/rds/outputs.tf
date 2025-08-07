# modules/rds/outputs.tf
output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.mysql.endpoint
}

output "db_port" {
  description = "RDS instance port"
  value       = aws_db_instance.mysql.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.mysql.db_name
}

output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.mysql.id
}

output "parameter_group_name" {
  description = "Parameter group name"
  value       = aws_db_parameter_group.mysql.name
}

