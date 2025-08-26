# modules/iam/outputs.tf
# Output values from the IAM module

output "s3_policy_arn" {
  description = "ARN of the S3 data lake access policy"
  value       = aws_iam_policy.s3_data_lake_policy.arn
}

output "s3_policy_name" {
  description = "Name of the S3 data lake access policy"
  value       = aws_iam_policy.s3_data_lake_policy.name
}