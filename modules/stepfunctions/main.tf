# modules/stepfunctions/main.tf
# Step Functions module for ETL orchestration

# Redshift Data API policy
resource "aws_iam_policy" "redshift_data_api" {
  name        = "de-proj-redshift-policy-api-data"
  description = "Policy for Step Functions to execute Redshift Data API commands"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "redshift-data:DescribeStatement",
          "redshift-data:ExecuteStatement",
          "redshift-data:GetStatementResult",
          "redshift-data:ListStatements"
        ]
        Resource = var.redshift_workgroup_arn
      }
    ]
  })

  tags = var.common_tags
}

# Glue job execution policy
resource "aws_iam_policy" "glue_job_execution" {
  name        = "de-proj-glue-job-run-policy"
  description = "Policy for Step Functions to manage Glue job runs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "glue:StartJobRun",
          "glue:GetJobRun",
          "glue:GetJobRuns",
          "glue:BatchStopJobRun",
          "glue:StopJobRun"
        ]
        Resource = "arn:aws:glue:*:${data.aws_caller_identity.current.account_id}:job/*"
      }
    ]
  })

  tags = var.common_tags
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Step Functions execution role
resource "aws_iam_role" "step_functions_role" {
  name = var.step_functions_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.common_tags
}

# Attach Redshift Data API policy to Step Functions role
resource "aws_iam_role_policy_attachment" "sf_redshift_data_api" {
  role       = aws_iam_role.step_functions_role.name
  policy_arn = aws_iam_policy.redshift_data_api.arn
}

# Attach Glue job execution policy to Step Functions role
resource "aws_iam_role_policy_attachment" "sf_glue_execution" {
  role       = aws_iam_role.step_functions_role.name
  policy_arn = aws_iam_policy.glue_job_execution.arn
}

# Attach Secrets Manager access policy to Step Functions role
resource "aws_iam_role_policy_attachment" "sf_secrets_access" {
  role       = aws_iam_role.step_functions_role.name
  policy_arn = var.secrets_policy_arn
}

# Step Functions state machine definition using external template
resource "aws_sfn_state_machine" "etl_orchestration" {
  name     = var.state_machine_name
  role_arn = aws_iam_role.step_functions_role.arn

  # Read from external JSON file and substitute variables
  definition = templatefile("${path.module}/harrys_state_machine.json.tpl", {
    product_transform_job      = var.product_transform_job
    customer_transform_job     = var.customer_transform_job
    orders_transform_job       = var.orders_transform_job
    orderdetails_transform_job = var.orderdetails_transform_job
    product_load_job          = var.product_load_job
    customer_load_job         = var.customer_load_job
    orders_load_job           = var.orders_load_job
    orderdetails_load_job     = var.orderdetails_load_job
    redshift_workgroup_name   = var.redshift_workgroup_name
    redshift_secret_arn       = var.redshift_secret_arn
  })

  tags = var.common_tags
}