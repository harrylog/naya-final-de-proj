# modules/s3/main.tf
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket for Data Lake
resource "aws_s3_bucket" "data_lake" {
  bucket = "${var.project_name}-${var.environment}-rds-cdc-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-cdc"
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "Data Lake for CDC"
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create folder structure using S3 objects
resource "aws_s3_object" "bronze_data_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "bronze_data/"
  source = "/dev/null"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_object" "silver_data_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "silver_data/"
  source = "/dev/null"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Bronze data table folders
resource "aws_s3_object" "bronze_customer_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "bronze_data/customer/"
  source = "/dev/null"
}

resource "aws_s3_object" "bronze_orders_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "bronze_data/orders/"
  source = "/dev/null"
}

resource "aws_s3_object" "bronze_product_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "bronze_data/product/"
  source = "/dev/null"
}

resource "aws_s3_object" "bronze_order_details_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "bronze_data/order_details/"
  source = "/dev/null"
}

# Silver data table folders
resource "aws_s3_object" "silver_customer_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "silver_data/customer/"
  source = "/dev/null"
}

resource "aws_s3_object" "silver_orders_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "silver_data/orders/"
  source = "/dev/null"
}

resource "aws_s3_object" "silver_product_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "silver_data/product/"
  source = "/dev/null"
}

resource "aws_s3_object" "silver_order_details_folder" {
  bucket = aws_s3_bucket.data_lake.id
  key    = "silver_data/orderDetails/"
  source = "/dev/null"
}