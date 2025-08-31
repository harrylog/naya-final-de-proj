{
  "Comment": "Simplified ETL Pipeline Orchestration",
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
                "JobName": "${product_load_job}"
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
          "StartAt": "LoadCustomerDimension",
          "States": {
            "LoadCustomerDimension": {
              "Type": "Task",
              "Resource": "arn:aws:states:::glue:startJobRun.sync",
              "Parameters": {
                "JobName": "${customer_load_job}"
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