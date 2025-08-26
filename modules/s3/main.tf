# modules/s3/main.tf
# S3 module for data lake storage (bronze/silver layers)

# Create the main S3 bucket for data lake
resource "aws_s3_bucket" "data_lake" {
  bucket = var.bucket_name

  tags = var.common_tags
}

# Configure bucket versioning (default enabled)
resource "aws_s3_bucket_versioning" "data_lake_versioning" {
  bucket = aws_s3_bucket.data_lake.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configure server-side encryption (default AWS managed)
resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake_encryption" {
  bucket = aws_s3_bucket.data_lake.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access (security best practice)
resource "aws_s3_bucket_public_access_block" "data_lake_pab" {
  bucket = aws_s3_bucket.data_lake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create folder structure for data lake layers
# Bronze layer folders (raw data from source systems)
resource "aws_s3_object" "bronze_folders" {
  for_each = toset(var.bronze_table_folders)
  
  bucket = aws_s3_bucket.data_lake.id
  key    = "bronze_data/${each.value}/"
  content_type = "application/x-directory"
  
  tags = var.common_tags
}

# Silver layer folders (processed/cleaned data)
resource "aws_s3_object" "silver_folders" {
  for_each = toset(var.silver_table_folders)
  
  bucket = aws_s3_bucket.data_lake.id
  key    = "silver_data/${each.value}/"
  content_type = "application/x-directory"
  
  tags = var.common_tags
}