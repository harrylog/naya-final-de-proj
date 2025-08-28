# modules/glue/outputs.tf
# Output values from the Glue module

output "glue_role_arn" {
  description = "ARN of the Glue IAM role"
  value       = aws_iam_role.glue_role.arn
}

output "glue_database_name" {
  description = "Name of the Glue database"
  value       = aws_glue_catalog_database.glue_database.name
}

output "crawler_name" {
  description = "Name of the Glue crawler"
  value       = aws_glue_crawler.product_crawler.name
}

output "etl_job_name" {
  description = "Name of the Glue ETL job"
  value       = aws_glue_job.product_etl.name
}

output "etl_job_arn" {
  description = "ARN of the Glue ETL job"
  value       = aws_glue_job.product_etl.arn
}

# ADD THESE TO modules/glue/outputs.tf

output "s3_gateway_endpoint_id" {
  description = "ID of the S3 gateway VPC endpoint"
  value       = aws_vpc_endpoint.s3_gateway.id
}

output "secretsmanager_endpoint_id" {
  description = "ID of the Secrets Manager VPC endpoint"
  value       = aws_vpc_endpoint.secretsmanager.id
}

output "sts_endpoint_id" {
  description = "ID of the STS VPC endpoint"
  value       = aws_vpc_endpoint.sts.id
}