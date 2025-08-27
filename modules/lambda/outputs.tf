# modules/lambda/outputs.tf
# Output values from the Lambda module

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.data_generator.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.data_generator.function_name
}

output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_role.arn
}

output "secrets_policy_arn" {
  description = "ARN of the Secrets Manager access policy"
  value       = aws_iam_policy.secrets_manager_policy.arn
}