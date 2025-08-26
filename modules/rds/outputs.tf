# modules/rds/outputs.tf
# Output values from the RDS module
# These can be used by other modules or displayed to the user

output "db_endpoint" {
  description = "The RDS instance endpoint"
  value       = aws_db_instance.mysql_db.endpoint
}

output "db_port" {
  description = "The RDS instance port"
  value       = aws_db_instance.mysql_db.port
}

output "db_identifier" {
  description = "The RDS instance identifier"
  value       = aws_db_instance.mysql_db.identifier
}

output "db_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.mysql_db.arn
}

output "parameter_group_name" {
  description = "The name of the parameter group"
  value       = aws_db_parameter_group.mysql_params.name
}

output "parameter_group_arn" {
  description = "The ARN of the parameter group"
  value       = aws_db_parameter_group.mysql_params.arn
}

output "db_instance_status" {
  description = "The current status of the RDS instance"
  value       = aws_db_instance.mysql_db.status
}

output "db_engine_version" {
  description = "The actual engine version of the RDS instance"
  value       = aws_db_instance.mysql_db.engine_version_actual
}