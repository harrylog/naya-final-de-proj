# modules/glue/main.tf
# AWS Glue for ETL processing

# Create IAM role for Glue
resource "aws_iam_role" "glue_role" {
  name = var.glue_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# Attach AWS managed Glue service policy
resource "aws_iam_role_policy_attachment" "glue_service" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Attach S3 access policy to Glue role
resource "aws_iam_role_policy_attachment" "glue_s3_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = var.s3_policy_arn
}

# Create custom policy for Glue to pass its own role
resource "aws_iam_policy" "glue_pass_role" {
  name        = "${var.glue_role_name}-pass-role-policy"
  description = "Allow Glue to pass its own role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = aws_iam_role.glue_role.arn
      }
    ]
  })

  tags = var.common_tags
}

# Attach pass role policy
resource "aws_iam_role_policy_attachment" "glue_pass_role" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_pass_role.arn
}

# Create Glue database
resource "aws_glue_catalog_database" "glue_database" {
  name = var.glue_database_name

  tags = var.common_tags
}

# Create Glue crawler
resource "aws_glue_crawler" "product_crawler" {
  database_name = aws_glue_catalog_database.glue_database.name
  name         = var.crawler_name
  role         = aws_iam_role.glue_role.arn



  s3_target {
  path = "s3://${var.s3_bucket_name}/bronze_data/dev/Product/"  
  exclusions = []

  }

  configuration = jsonencode({
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
    CrawlerOutput = {
      Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
      Tables     = { AddOrUpdateBehavior = "MergeNewColumns" }
    }
    Version = 1
  })

  table_prefix = var.table_prefix

  tags = var.common_tags
}

# Upload Glue ETL script to S3
resource "aws_s3_object" "glue_script" {
  bucket = var.s3_bucket_name
  key    = "glue-scripts/${var.etl_script_name}"
  source = var.etl_script_path
  etag   = filemd5(var.etl_script_path)

  tags = var.common_tags
}

# Create Glue ETL job
resource "aws_glue_job" "product_etl" {
  name         = var.etl_job_name
  role_arn     = aws_iam_role.glue_role.arn
  glue_version = "4.0"

  command {
    script_location = "s3://${var.s3_bucket_name}/glue-scripts/${var.etl_script_name}"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--job-bookmark-option"             = "job-bookmark-enable"
    "--enable-metrics"                  = ""
    "--enable-spark-ui"                 = "true"
    "--spark-event-logs-path"           = "s3://${var.s3_bucket_name}/sparkHistoryLogs/"
    "--enable-job-insights"             = "false"
    "--enable-observability-metrics"    = "true"
    "--enable-glue-datacatalog"         = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--TempDir"                         = "s3://${var.s3_bucket_name}/temporary/"
  }

  execution_property {
    max_concurrent_runs = 1
  }

  max_retries = 0
  timeout     = 2880
  worker_type = "G.1X"
  number_of_workers = 2

  tags = var.common_tags

  depends_on = [aws_s3_object.glue_script]
}

# ADD THESE TO modules/glue/main.tf (after the existing crawler)

# Customer crawler
resource "aws_glue_crawler" "customer_crawler" {
  database_name = aws_glue_catalog_database.glue_database.name
  name         = "de-proj-customer-crawler"
  role         = aws_iam_role.glue_role.arn

  s3_target {
    path = "s3://${var.s3_bucket_name}/bronze_data/dev/Customer/"
  }

  table_prefix = var.table_prefix
  tags = var.common_tags
}

# Orders crawler
resource "aws_glue_crawler" "orders_crawler" {
  database_name = aws_glue_catalog_database.glue_database.name
  name         = "de-proj-orders-crawler"
  role         = aws_iam_role.glue_role.arn

  s3_target {
    path = "s3://${var.s3_bucket_name}/bronze_data/dev/Orders/"
  }

  table_prefix = var.table_prefix
  tags = var.common_tags
}

# OrderDetails crawler
resource "aws_glue_crawler" "orderdetails_crawler" {
  database_name = aws_glue_catalog_database.glue_database.name
  name         = "de-proj-orderdetails-crawler"
  role         = aws_iam_role.glue_role.arn

  s3_target {
    path = "s3://${var.s3_bucket_name}/bronze_data/dev/orderDetails/"
  }

  table_prefix = var.table_prefix
  tags = var.common_tags
}


# ADD THESE ETL SCRIPTS TO S3 AND CREATE JOBS

# Upload Customer ETL script
resource "aws_s3_object" "customer_glue_script" {
  bucket = var.s3_bucket_name
  key    = "glue-scripts/raw_customer_etl_job.py"
  source = "raw_customer_etl_job.py"
  etag   = filemd5("raw_customer_etl_job.py")
  tags = var.common_tags
}

# Upload Orders ETL script  
resource "aws_s3_object" "orders_glue_script" {
  bucket = var.s3_bucket_name
  key    = "glue-scripts/raw_orders_etl_job.py"
  source = "raw_orders_etl_job.py"
  etag   = filemd5("raw_orders_etl_job.py")
  tags = var.common_tags
}

# Upload OrderDetails ETL script
resource "aws_s3_object" "orderdetails_glue_script" {
  bucket = var.s3_bucket_name
  key    = "glue-scripts/raw_orderdetails_etl_job.py"
  source = "raw_orderdetails_etl_job.py"
  etag   = filemd5("raw_orderdetails_etl_job.py")
  tags = var.common_tags
}

# Customer ETL Job
resource "aws_glue_job" "customer_etl" {
  name         = "de-proj-customer-etl-job"
  role_arn     = aws_iam_role.glue_role.arn
  glue_version = "4.0"

  command {
    script_location = "s3://${var.s3_bucket_name}/glue-scripts/raw_customer_etl_job.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--job-bookmark-option"             = "job-bookmark-enable"
    "--enable-metrics"                  = ""
    "--enable-spark-ui"                 = "true"
    "--spark-event-logs-path"           = "s3://${var.s3_bucket_name}/sparkHistoryLogs/"
    "--enable-job-insights"             = "false"
    "--enable-observability-metrics"    = "true"
    "--enable-glue-datacatalog"         = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--TempDir"                         = "s3://${var.s3_bucket_name}/temporary/"
  }

  execution_property {
    max_concurrent_runs = 1
  }

  max_retries = 0
  timeout     = 2880
  worker_type = "G.1X"
  number_of_workers = 2
  tags = var.common_tags
  depends_on = [aws_s3_object.customer_glue_script]
}

# Orders ETL Job
resource "aws_glue_job" "orders_etl" {
  name         = "de-proj-orders-etl-job"
  role_arn     = aws_iam_role.glue_role.arn
  glue_version = "4.0"

  command {
    script_location = "s3://${var.s3_bucket_name}/glue-scripts/raw_orders_etl_job.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--job-bookmark-option"             = "job-bookmark-enable"
    "--enable-metrics"                  = ""
    "--enable-spark-ui"                 = "true"
    "--spark-event-logs-path"           = "s3://${var.s3_bucket_name}/sparkHistoryLogs/"
    "--enable-job-insights"             = "false"
    "--enable-observability-metrics"    = "true"
    "--enable-glue-datacatalog"         = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--TempDir"                         = "s3://${var.s3_bucket_name}/temporary/"
  }

  execution_property {
    max_concurrent_runs = 1
  }

  max_retries = 0
  timeout     = 2880
  worker_type = "G.1X"
  number_of_workers = 2
  tags = var.common_tags
  depends_on = [aws_s3_object.orders_glue_script]
}

# OrderDetails ETL Job
resource "aws_glue_job" "orderdetails_etl" {
  name         = "de-proj-orderdetails-etl-job"
  role_arn     = aws_iam_role.glue_role.arn
  glue_version = "4.0"

  command {
    script_location = "s3://${var.s3_bucket_name}/glue-scripts/raw_orderdetails_etl_job.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--job-bookmark-option"             = "job-bookmark-enable"
    "--enable-metrics"                  = ""
    "--enable-spark-ui"                 = "true"
    "--spark-event-logs-path"           = "s3://${var.s3_bucket_name}/sparkHistoryLogs/"
    "--enable-job-insights"             = "false"
    "--enable-observability-metrics"    = "true"
    "--enable-glue-datacatalog"         = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--TempDir"                         = "s3://${var.s3_bucket_name}/temporary/"
  }

  execution_property {
    max_concurrent_runs = 1
  }

  max_retries = 0
  timeout     = 2880
  worker_type = "G.1X"  
  number_of_workers = 2
  tags = var.common_tags
  depends_on = [aws_s3_object.orderdetails_glue_script]
}