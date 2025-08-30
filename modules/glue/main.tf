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
# ADD THESE DATA SOURCES TO THE TOP of modules/glue/main.tf (after existing data sources)

# Get default VPC for VPC endpoints
data "aws_vpc" "default" {
  default = true
}

# Get all subnets in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
# ADD THESE TO modules/glue/main.tf (after existing resources)

# Get route tables for VPC endpoints
data "aws_route_tables" "default" {
  vpc_id = data.aws_vpc.default.id
}

# Create Redshift Secrets Manager policy
resource "aws_iam_policy" "glue_redshift_secrets" {
  name        = "de-proj-get-redshift-secret-policy"
  description = "Allow Glue to access Redshift credentials from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.redshift_secret_arn
      }
    ]
  })

  tags = var.common_tags
}

# Attach Redshift secrets policy to Glue role
resource "aws_iam_role_policy_attachment" "glue_redshift_secrets" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_redshift_secrets.arn
}

# Attach VPC full access to Glue role
resource "aws_iam_role_policy_attachment" "glue_vpc_access" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
}

# S3 Gateway VPC Endpoint
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id       = data.aws_vpc.default.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
  
  vpc_endpoint_type = "Gateway"
  route_table_ids   = data.aws_route_tables.default.ids

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:*"
        Resource = "*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "de-proj-s3-gateway"
  })
}

# Get current AWS region
data "aws_region" "current" {}

# Secrets Manager Interface VPC Endpoint
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id       = data.aws_vpc.default.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.aws_subnets.default.ids
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "secretsmanager:*"
        Resource = "*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "de-proj-secret-mngr-endpoint"
  })
}

# STS Interface VPC Endpoint
resource "aws_vpc_endpoint" "sts" {
  vpc_id       = data.aws_vpc.default.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.sts"
  
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.aws_subnets.default.ids
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "sts:*"
        Resource = "*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "de-proj-sts-endpoint"
  })
}

# Security group for VPC endpoints
resource "aws_security_group" "vpc_endpoint_sg" {
  name_prefix = "vpc-endpoint-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = data.aws_vpc.default.id

  # Allow HTTPS traffic for interface endpoints
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "vpc-endpoints-security-group"
  })
}

# ADD TO modules/glue/main.tf (after other VPC endpoints)

# Redshift Serverless Interface VPC Endpoint
# REPLACE the aws_vpc_endpoint "redshift" resource in modules/glue/main.tf with this:

# Get specific subnets in supported AZs for Redshift Serverless
data "aws_subnets" "redshift_compatible" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  
  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b"] # Use commonly supported AZs
  }
}

# Redshift Serverless Interface VPC Endpoint (with specific subnets)
resource "aws_vpc_endpoint" "redshift" {
  vpc_id       = data.aws_vpc.default.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.redshift-serverless"
  
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.aws_subnets.redshift_compatible.ids
  security_group_ids  = [aws_security_group.vpc_endpoint_sg_open.id]
  private_dns_enabled = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "redshift-serverless:*"
        Resource = "*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "de-prog-redshift-endpoint"
  })
}

# Open security group for Redshift endpoint (as requested)
resource "aws_security_group" "vpc_endpoint_sg_open" {
  name_prefix = "vpc-endpoint-open-sg"
  description = "Open security group for VPC endpoints"
  vpc_id      = data.aws_vpc.default.id

  # Allow all TCP traffic (as requested - not recommended for production)
  ingress {
    description = "All TCP traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "vpc-endpoints-open-security-group"
  })
}

# ADD TO modules/glue/main.tf (after VPC endpoints)

# Glue connection to Redshift
resource "aws_glue_connection" "redshift_connection" {
  name = "redshift-connection"
  
  connection_type = "JDBC"
  
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:redshift://${var.redshift_endpoint}:5439/production"
    USERNAME           = "admin"
    PASSWORD           = var.redshift_secret_arn # Reference to secret
  }
  
  physical_connection_requirements {
    availability_zone      = data.aws_subnets.default.ids[0]
    security_group_id_list = [aws_security_group.vpc_endpoint_sg_open.id]
    subnet_id             = data.aws_subnets.default.ids[0]
  }

  tags = var.common_tags
}


# ADD THESE LOADING JOBS TO modules/glue/main.tf

# Upload loading job scripts to S3
resource "aws_s3_object" "load_product_script" {
  bucket = var.s3_bucket_name
  key    = "glue-scripts/de-proj-load-product-job.py"
  source = "de-proj-load-product-job.py"
  etag   = filemd5("de-proj-load-product-job.py")
  tags   = var.common_tags
}

resource "aws_s3_object" "load_customer_script" {
  bucket = var.s3_bucket_name
  key    = "glue-scripts/de-proj0load-customer-job.py"
  source = "de-proj0load-customer-job.py"
  etag   = filemd5("de-proj0load-customer-job.py")
  tags   = var.common_tags
}

# Create loading jobs
resource "aws_glue_job" "load_product" {
  name         = "de-proj-load-product-job"
  role_arn     = aws_iam_role.glue_role.arn
  glue_version = "4.0"
  
  connections = [aws_glue_connection.redshift_connection.name]

  command {
    script_location = "s3://${var.s3_bucket_name}/glue-scripts/de-proj-load-product-job.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--job-bookmark-option"             = "job-bookmark-enable"
    "--enable-metrics"                  = ""
    "--enable-spark-ui"                 = "true"
    "--enable-glue-datacatalog"         = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--TempDir"                         = "s3://${var.s3_bucket_name}/temporary/"
  }

  execution_property {
    max_concurrent_runs = 1
  }

  worker_type = "G.1X"
  number_of_workers = 2
  tags = var.common_tags
  
  depends_on = [aws_s3_object.load_product_script]
}

# Similar pattern for other loading jobs...
resource "aws_glue_job" "load_customer" {
  name         = "de-proj0load-customer-job"
  role_arn     = aws_iam_role.glue_role.arn
  glue_version = "4.0"
  
  connections = [aws_glue_connection.redshift_connection.name]

  command {
    script_location = "s3://${var.s3_bucket_name}/glue-scripts/de-proj0load-customer-job.py"
    python_version  = "3"
  }

  # Same default arguments...
  default_arguments = {
    "--job-language"                     = "python"
    "--job-bookmark-option"             = "job-bookmark-enable"
    "--enable-metrics"                  = ""
    "--enable-spark-ui"                 = "true"
    "--enable-glue-datacatalog"         = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--TempDir"                         = "s3://${var.s3_bucket_name}/temporary/"
  }

  execution_property {
    max_concurrent_runs = 1
  }

  worker_type = "G.1X"
  number_of_workers = 2
  tags = var.common_tags
  
  depends_on = [aws_s3_object.load_customer_script]
}

# Orders loading job
resource "aws_glue_job" "load_orders" {
  name         = "de-proj-load-order-job"
  role_arn     = aws_iam_role.glue_role.arn
  glue_version = "5.0"  # Match the version from console
  
  connections = [aws_glue_connection.redshift_connection.name]

  command {
    script_location = "s3://${var.s3_bucket_name}/glue-scripts/de-proj-load-order-job.py"
    python_version  = "3"
  }

  default_arguments = {
    "--job-language"                     = "python"
    "--job-bookmark-option"             = "job-bookmark-enable"
    "--enable-metrics"                  = ""
    "--enable-spark-ui"                 = "true"
    "--enable-glue-datacatalog"         = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--TempDir"                         = "s3://${var.s3_bucket_name}/temporary/"
  }

  execution_property {
    max_concurrent_runs = 1
  }

  worker_type = "G.1X"
  number_of_workers = 2
  tags = var.common_tags
}

# OrderDetails loading job
resource "aws_glue_job" "load_orderdetails" {
  name         = "de-proj-load-ordersdetails-job"
  role_arn     = aws_iam_role.glue_role.arn
  glue_version = "5.0"
  
  connections = [aws_glue_connection.redshift_connection.name]

  command {
    script_location = "s3://${var.s3_bucket_name}/glue-scripts/de-proj-load-ordersdetails-job.py"
    python_version  = "3"
  }

  # Same default_arguments and configuration...
  default_arguments = {
    "--job-language"                     = "python"
    "--job-bookmark-option"             = "job-bookmark-enable"
    "--enable-metrics"                  = ""
    "--enable-spark-ui"                 = "true"
    "--enable-glue-datacatalog"         = "true"
    "--enable-continuous-cloudwatch-log" = "true"
    "--TempDir"                         = "s3://${var.s3_bucket_name}/temporary/"
  }

  execution_property {
    max_concurrent_runs = 1
  }

  worker_type = "G.1X"
  number_of_workers = 2
  tags = var.common_tags
}