# modules/s3/outputs.tf
# Output values from the S3 data lake module

output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.data_lake.bucket
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.data_lake.arn
}

output "bucket_id" {
  description = "ID of the created S3 bucket"
  value       = aws_s3_bucket.data_lake.id
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.data_lake.bucket_domain_name
}

output "bronze_folders" {
  description = "List of created bronze layer folders"
  value       = [for folder in aws_s3_object.bronze_folders : folder.key]
}

output "silver_folders" {
  description = "List of created silver layer folders"
  value       = [for folder in aws_s3_object.silver_folders : folder.key]
}