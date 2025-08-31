{
  "Comment": "ETL Pipeline Orchestration with Status Monitoring",
  "StartAt": "TransformationJobsParallel",
  "States": {
    "TransformationJobsParallel": {
      "Type": "Parallel",
      "Next": "LoadDimensionsParallel",
      "Branches": [
        {
          "StartAt": "TransformProducts",
          "States": {
            "TransformProducts": {
              "Type": "Task",
              "Resource": "arn:aws:states:::glue:startJobRun.sync",
              "Parameters": {
               "JobName": "${product_transform_job}"
              },
              "End": true,
              "Retry": [
                {
                  "ErrorEquals": ["States.TaskFailed"],
                  "BackoffRate": 2,
                  "IntervalSeconds": 1,
                  "MaxAttempts": 3
                }
              ]
            }
          }
        },
        {
          "StartAt": "TransformCustomers",
          "States": {
            "TransformCustomers": {
              "Type": "Task",
              "Resource": "arn:aws:states:::glue:startJobRun.sync",
              "Parameters": {
               "JobName": "${customer_transform_job}"
              },
              "End": true,
              "Retry": [
                {
                  "ErrorEquals": ["States.TaskFailed"],
                  "BackoffRate": 2,
                  "IntervalSeconds": 1,
                  "MaxAttempts": 3
                }
              ]
            }
          }
        },
        {
          "StartAt": "TransformOrders",
          "States": {
            "TransformOrders": {
              "Type": "Task",
              "Resource": "arn:aws:states:::glue:startJobRun.sync",
              "Parameters": {
                "JobName": "${orders_transform_job}"
              },
              "End": true,
              "Retry": [
                {
                  "ErrorEquals": ["States.TaskFailed"],
                  "BackoffRate": 2,
                  "IntervalSeconds": 1,
                  "MaxAttempts": 3
                }
              ]
            }
          }
        },
        {
          "StartAt": "TransformOrderDetails",
          "States": {
            "TransformOrderDetails": {
              "Type": "Task",
              "Resource": "arn:aws:states:::glue:startJobRun.sync",
              "Parameters": {
                "JobName": "${orderdetails_transform_job}"
              },
              "End": true,
              "Retry": [
                {
                  "ErrorEquals": ["States.TaskFailed"],
                  "BackoffRate": 2,
                  "IntervalSeconds": 1,
                  "MaxAttempts": 3
                }
              ]
            }
          }
        }
      ]
    },
    "LoadDimensionsParallel": {
      "Type": "Parallel",
      "Next": "LoadFactsParallel",
      "Branches": [
        {
          "StartAt": "LoadProductDimension",
          "States": {
            "LoadProductDimension": {
              "Type": "Task",
              "Resource": "arn:aws:states:::glue:startJobRun.sync",
              "Parameters": {
              "JobName": "${product_load_job}"              },
              "Next": "ExecuteProductSP",
              "Retry": [
                {
                  "ErrorEquals": ["States.TaskFailed"],
                  "BackoffRate": 2,
                  "IntervalSeconds": 1,
                  "MaxAttempts": 3
                }
              ]
            },
            "ExecuteProductSP": {
              "Type": "Task",
              "Resource": "arn:aws:states:::aws-sdk:redshiftdata:executeStatement",
              "Parameters": {
                "Database": "production",
                "Sql": "CALL sales.sp_merge_dim_product();",
                "WorkgroupName": "${redshift_workgroup_name}",
                "SecretArn": "${redshift_secret_arn}"              },
              "ResultPath": "$.sp_result",
              "Next": "WaitProductSP"
            },
            "WaitProductSP": {
              "Type": "Wait",
              "Seconds": 5,
              "Next": "CheckProductSPStatus"
            },
            "CheckProductSPStatus": {
              "Type": "Task",
              "Resource": "arn:aws:states:::aws-sdk:redshiftdata:describeStatement",
              "Parameters": {
                "Id.$": "$.sp_result.Id"
              },
              "ResultPath": "$.status_result",
              "Next": "IsProductSPComplete"
            },
            "IsProductSPComplete": {
              "Type": "Choice",
              "Choices": [
                {
                  "Variable": "$.status_result.Status",
                  "StringEquals": "FAILED",
                  "Next": "ProductSPFailure"
                },
                {
                  "Variable": "$.status_result.Status",
                  "StringEquals": "FINISHED",
                  "Next": "ProductSPSuccess"
                }
              ],
              "Default": "WaitProductSP"
            },
            "ProductSPSuccess": {
              "Type": "Pass",
              "End": true
            },
            "ProductSPFailure": {
              "Type": "Fail",
              "Cause": "Product stored procedure failed",
              "Error": "StoredProcedureError"
            }
          }
        },
        {
          "StartAt": "LoadCustomerDimension",
          "States": {
            "LoadCustomerDimension": {
              "Type": "Task",
              "Resource": "arn:aws:states:::glue:startJobRun.sync",
              "Parameters": {
                "JobName": "${customer_load_job}"
              },
              "Next": "ExecuteCustomerSP",
              "Retry": [
                {
                  "ErrorEquals": ["States.TaskFailed"],
                  "BackoffRate": 2,
                  "IntervalSeconds": 1,
                  "MaxAttempts": 3
                }
              ]
            },
            "ExecuteCustomerSP": {
              "Type": "Task",
              "Resource": "arn:aws:states:::aws-sdk:redshiftdata:executeStatement",
              "Parameters": {
                "Database": "production",
                "Sql": "CALL sales.sp_merge_dim_customer();",
                "WorkgroupName": "${redshift_workgroup_name}",
                "SecretArn": "${redshift_secret_arn}"              },
              "ResultPath": "$.sp_result",
              "Next": "WaitCustomerSP"
            },
            "WaitCustomerSP": {
              "Type": "Wait",
              "Seconds": 5,
              "Next": "CheckCustomerSPStatus"
            },
            "CheckCustomerSPStatus": {
              "Type": "Task",
              "Resource": "arn:aws:states:::aws-sdk:redshiftdata:describeStatement",
              "Parameters": {
                "Id.$": "$.sp_result.Id"
              },
              "ResultPath": "$.status_result",
              "Next": "IsCustomerSPComplete"
            },
            "IsCustomerSPComplete": {
              "Type": "Choice",
              "Choices": [
                {
                  "Variable": "$.status_result.Status",
                  "StringEquals": "FAILED",
                  "Next": "CustomerSPFailure"
                },
                {
                  "Variable": "$.status_result.Status",
                  "StringEquals": "FINISHED",
                  "Next": "CustomerSPSuccess"
                }
              ],
              "Default": "WaitCustomerSP"
            },
            "CustomerSPSuccess": {
              "Type": "Pass",
              "End": true
            },
            "CustomerSPFailure": {
              "Type": "Fail",
              "Cause": "Customer stored procedure failed",
              "Error": "StoredProcedureError"
            }
          }
        }
      ]
    },
    "LoadFactsParallel": {
      "Type": "Parallel",
      "End": true,
      "Branches": [
        {
          "StartAt": "LoadOrdersFact",
          "States": {
            "LoadOrdersFact": {
              "Type": "Task",
              "Resource": "arn:aws:states:::glue:startJobRun.sync",
              "Parameters": {
                "JobName": "${orders_load_job}"
              },
              "End": true,
              "Retry": [
                {
                  "ErrorEquals": ["States.TaskFailed"],
                  "BackoffRate": 2,
                  "IntervalSeconds": 1,
                  "MaxAttempts": 3
                }
              ]
            }
          }
        },
        {
          "StartAt": "LoadOrderDetailsFact",
          "States": {
            "LoadOrderDetailsFact": {
              "Type": "Task",
              "Resource": "arn:aws:states:::glue:startJobRun.sync",
              "Parameters": {
                "JobName": "${orderdetails_load_job}"
              },
              "End": true,
              "Retry": [
                {
                  "ErrorEquals": ["States.TaskFailed"],
                  "BackoffRate": 2,
                  "IntervalSeconds": 1,
                  "MaxAttempts": 3
                }
              ]
            }
          }
        }
      ]
    }
  }
}
