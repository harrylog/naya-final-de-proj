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