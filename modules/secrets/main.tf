# modules/secrets/main.tf
# AWS Secrets Manager for database credentials

# Create the secret for RDS database credentials
# REPLACE the aws_secretsmanager_secret resource in modules/secrets/main.tf with this:

resource "aws_secretsmanager_secret" "rds_credentials" {
  name        = var.secret_name
  description = "Database credentials for RDS MySQL instance"

  tags = var.common_tags
}

# Get current AWS region
data "aws_region" "current" {}

# Store the actual secret values
resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  
  secret_string = jsonencode({
    hostname = var.rds_hostname
    username = var.rds_username  
    password = var.rds_password
    dbname   = var.rds_dbname
  })
}