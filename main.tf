# Root main.tf
# This is the main configuration file that orchestrates the entire project

# Configure the AWS Provider
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider region
provider "aws" {
  region = var.aws_region
}

# Call the RDS module
# This demonstrates how to use modules in Terraform
module "mysql_database" {
  source = "./modules/rds"
  
  # Pass variables to the module
  db_identifier           = var.db_identifier
  db_name                = var.db_name
  master_username        = var.master_username
  master_password        = var.master_password
  parameter_group_name   = var.parameter_group_name
  parameter_group_description = var.parameter_group_description
  
  # Optional: Add tags for resource management
  common_tags = var.common_tags
}


# ADD THIS TO main.tf (after the RDS module)

# Call the S3 data lake module
module "data_lake" {
  source = "./modules/s3"
  
  bucket_name = var.s3_bucket_name
  common_tags = var.common_tags
}

# ADD THIS TO main.tf (after the S3 module)

# Call the IAM module for policies and roles
module "iam_policies" {
  source = "./modules/iam"
  
  s3_bucket_arn = module.data_lake.bucket_arn
  common_tags   = var.common_tags
}


# ADD THIS TO main.tf (after the IAM module)

# Call the DMS module for database migration
module "dms_migration" {
  source = "./modules/dms"
  
  common_tags = var.common_tags
}