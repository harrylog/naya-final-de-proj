# modules/redshift/outputs.tf
# Output values from the Redshift module

output "workgroup_arn" {
  description = "ARN of the Redshift serverless workgroup"
  value       = aws_redshiftserverless_workgroup.workgroup.arn
}

output "workgroup_id" {
  description = "ID of the Redshift serverless workgroup"
  value       = aws_redshiftserverless_workgroup.workgroup.id
}

output "namespace_arn" {
  description = "ARN of the Redshift serverless namespace"
  value       = aws_redshiftserverless_namespace.namespace.arn
}

output "endpoint_address" {
  description = "Redshift serverless endpoint address"
  value       = try(aws_redshiftserverless_workgroup.workgroup.endpoint[0].address, "")
}

output "endpoint_port" {
  description = "Redshift serverless endpoint port"
  value       = 5439
}

output "redshift_role_arn" {
  description = "ARN of the Redshift IAM role"
  value       = aws_iam_role.redshift_role.arn
}

output "secret_arn" {
  description = "ARN of the Redshift credentials secret"
  value       = aws_secretsmanager_secret.redshift_credentials.arn
}