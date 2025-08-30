# modules/lambda/variables.tf
# Input variables for the Lambda module

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "de-proj-data-gen-lambda"
}

variable "lambda_role_name" {
  description = "Name of the IAM role for Lambda execution"
  type        = string
  default     = "de-proj-lambda-role"
}

variable "secrets_policy_name" {
  description = "Name of the Secrets Manager access policy"
  type        = string
  default     = "de-prog-get-rds-secrete-policy"
}

variable "timeout_seconds" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 360  # 6 minutes
}

variable "lambda_source_file" {
  description = "Path to Lambda source file"
  type        = string  
  default     = "lambda_function.py"
}

variable "secret_name" {
  description = "Name of the secret in AWS Secrets Manager"
  type        = string
}

variable "rds_secret_arn" {
  description = "ARN of the RDS credentials secret"
  type        = string
}

variable "region_name" {
  description = "AWS region name"
  type        = string
  default     = "us-east-1"
}

variable "lambda_layers" {
  description = "List of Lambda layer ARNs for dependencies"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Common tags to apply to all Lambda resources"
  type        = map(string)
  default     = {}
}

# ADD THIS TO modules/lambda/variables.tf

variable "layer_name" {
  description = "Name of the Lambda layer"
  type        = string
  default     = "de-proj-python-deps-layer"
}