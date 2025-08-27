# modules/secrets/outputs.tf
# Output values from the Secrets Manager module

output "secret_arn" {
  description = "ARN of the RDS credentials secret"
  value       = aws_secretsmanager_secret.rds_credentials.arn
}

output "secret_name" {
  description = "Name of the RDS credentials secret"
  value       = aws_secretsmanager_secret.rds_credentials.name
}

output "secret_id" {
  description = "ID of the RDS credentials secret"
  value       = aws_secretsmanager_secret.rds_credentials.id
}