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

# Step Functions state machine definition
resource "aws_sfn_state_machine" "etl_orchestration" {
  name     = var.state_machine_name
  role_arn = aws_iam_role.step_functions_role.arn

  definition = jsonencode({
    Comment = "ETL Pipeline Orchestration"
    StartAt = "TransformationJobsParallel"
    States = {
      TransformationJobsParallel = {
        Type = "Parallel"
        Next = "LoadDimensionsParallel"
        Branches = [
          {
            StartAt = "TransformProducts"
            States = {
              TransformProducts = {
                Type = "Task"
                Resource = "arn:aws:states:::glue:startJobRun.sync"
                Parameters = {
                  JobName = var.product_transform_job
                }
                End = true
              }
            }
          },
          {
            StartAt = "TransformCustomers"
            States = {
              TransformCustomers = {
                Type = "Task"
                Resource = "arn:aws:states:::glue:startJobRun.sync"
                Parameters = {
                  JobName = var.customer_transform_job
                }
                End = true
              }
            }
          },
          {
            StartAt = "TransformOrders"
            States = {
              TransformOrders = {
                Type = "Task"
                Resource = "arn:aws:states:::glue:startJobRun.sync"
                Parameters = {
                  JobName = var.orders_transform_job
                }
                End = true
              }
            }
          },
          {
            StartAt = "TransformOrderDetails"
            States = {
              TransformOrderDetails = {
                Type = "Task"
                Resource = "arn:aws:states:::glue:startJobRun.sync"
                Parameters = {
                  JobName = var.orderdetails_transform_job
                }
                End = true
              }
            }
          }
        ]
      }
      LoadDimensionsParallel = {
        Type = "Parallel"
        Next = "ExecuteStoredProceduresParallel"
        Branches = [
          {
            StartAt = "LoadProductDimension"
            States = {
              LoadProductDimension = {
                Type = "Task"
                Resource = "arn:aws:states:::glue:startJobRun.sync"
                Parameters = {
                  JobName = var.product_load_job
                }
                End = true
              }
            }
          },
          {
            StartAt = "LoadCustomerDimension"
            States = {
              LoadCustomerDimension = {
                Type = "Task"
                Resource = "arn:aws:states:::glue:startJobRun.sync"
                Parameters = {
                  JobName = var.customer_load_job
                }
                End = true
              }
            }
          }
        ]
      }
      ExecuteStoredProceduresParallel = {
        Type = "Parallel"
        Next = "WaitForCompletion"
        Branches = [
          {
            StartAt = "ExecuteProductSP"
            States = {
              ExecuteProductSP = {
                Type = "Task"
                Resource = "arn:aws:states:::aws-sdk:redshiftdata:executeStatement"
                Parameters = {
                  WorkgroupName = var.redshift_workgroup_name
                  Database = "production"
                  Sql = "CALL sales.sp_merge_dim_product();"
                }
                End = true
              }
            }
          },
          {
            StartAt = "ExecuteCustomerSP"
            States = {
              ExecuteCustomerSP = {
                Type = "Task"
                Resource = "arn:aws:states:::aws-sdk:redshiftdata:executeStatement"
                Parameters = {
                  WorkgroupName = var.redshift_workgroup_name
                  Database = "production"
                  Sql = "CALL sales.sp_merge_dim_customer();"
                }
                End = true
              }
            }
          }
        ]
      }
      WaitForCompletion = {
        Type = "Wait"
        Seconds = 5
        Next = "LoadFactsParallel"
      }
      LoadFactsParallel = {
        Type = "Parallel"
        End = true
        Branches = [
          {
            StartAt = "LoadOrdersFact"
            States = {
              LoadOrdersFact = {
                Type = "Task"
                Resource = "arn:aws:states:::glue:startJobRun.sync"
                Parameters = {
                  JobName = var.orders_load_job
                }
                End = true
              }
            }
          },
          {
            StartAt = "LoadOrderDetailsFact"
            States = {
              LoadOrderDetailsFact = {
                Type = "Task"
                Resource = "arn:aws:states:::glue:startJobRun.sync"
                Parameters = {
                  JobName = var.orderdetails_load_job
                }
                End = true
              }
            }
          }
        ]
      }
    }
  })

  tags = var.common_tags
}