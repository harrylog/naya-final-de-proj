# modules/iam/outputs.tf
output "s3_policy_arn" {
  description = "ARN of the S3 access policy"
  value       = aws_iam_policy.s3_access.arn
}

output "dms_role_arn" {
  description = "ARN of the DMS access role"
  value       = aws_iam_role.dms_access_role.arn
}

output "glue_role_arn" {
  description = "ARN of the Glue service role"
  value       = aws_iam_role.glue_service_role.arn
}

output "dms_role_name" {
  description = "Name of the DMS access role"
  value       = aws_iam_role.dms_access_role.name
}

output "glue_role_name" {
  description = "Name of the Glue service role"
  value       = aws_iam_role.glue_service_role.name
}