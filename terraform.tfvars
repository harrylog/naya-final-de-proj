# terraform.tfvars
# This file contains the actual values for your variables
# It's where you customize the deployment without changing the code

# AWS Configuration
aws_region = "us-east-1"

# Database Configuration
db_identifier    = "naya-de-proj-mysql-db"
db_name         = "naya_de_db"
master_username = "admin"
master_password = "naya-de-proj-pwd-mysql8"

# Parameter Group Configuration
parameter_group_name        = "naya-de-proj-db-pg"
parameter_group_description = "Parameter group for MySQL configuration"

# Resource Tags
common_tags = {
  Project     = "naya-data-engineering"
  Environment = "development"
  Owner       = "naya-learning"
  Purpose     = "educational-etl-project"
}