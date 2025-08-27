# modules/lambda/main.tf
# Lambda function for data generation

# Create IAM role for Lambda execution
resource "aws_iam_role" "lambda_role" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.common_tags
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create custom policy for Secrets Manager access
resource "aws_iam_policy" "secrets_manager_policy" {
  name        = var.secrets_policy_name
  description = "Policy for Lambda to access RDS credentials from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.rds_secret_arn
      }
    ]
  })

  tags = var.common_tags
}

# Attach Secrets Manager policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_secrets_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

# Create dependencies package for Lambda layer
resource "null_resource" "lambda_dependencies" {
  triggers = {
    requirements = filemd5("${path.root}/requirements.txt")
  }

  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p ${path.module}/layer/python/lib/python3.13/site-packages
      pip install -r ${path.root}/requirements.txt -t ${path.module}/layer/python/lib/python3.13/site-packages
    EOT
  }
}

# Create Lambda layer zip file
data "archive_file" "lambda_layer_zip" {
  type        = "zip"
  source_dir  = "${path.module}/layer"
  output_path = "${path.module}/lambda_layer.zip"
  
  depends_on = [null_resource.lambda_dependencies]
}

# Create Lambda layer
resource "aws_lambda_layer_version" "python_dependencies" {
  filename            = data.archive_file.lambda_layer_zip.output_path
  layer_name          = var.layer_name
  compatible_runtimes = ["python3.13"]
  description         = "Python dependencies for data generator Lambda"

  depends_on = [data.archive_file.lambda_layer_zip]
}

# Create deployment package for Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = var.lambda_source_file
  output_path = "${path.module}/lambda_function.zip"
  
  # Force recreation when file content changes
  depends_on = [local_file.lambda_code_trigger]
}

# Detect changes in Lambda code
resource "local_file" "lambda_code_trigger" {
  content  = filemd5(var.lambda_source_file)
  filename = "${path.module}/.lambda_hash"
}

# Create Lambda function
resource "aws_lambda_function" "data_generator" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = var.function_name
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.13"
  timeout         = var.timeout_seconds
  architectures   = ["x86_64"]

  # Environment variables
  environment {
    variables = {
      SECRET_NAME = var.secret_name
      REGION_NAME = var.region_name
    }
  }

  # Lambda layers for dependencies (mysql-connector, faker)
  layers = [aws_lambda_layer_version.python_dependencies.arn]

  tags = var.common_tags

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy_attachment.lambda_secrets_access,
    aws_lambda_layer_version.python_dependencies
  ]
}