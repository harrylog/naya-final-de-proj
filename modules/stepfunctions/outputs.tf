# modules/stepfunctions/outputs.tf
# Output values from the Step Functions module

output "state_machine_arn" {
  description = "ARN of the Step Functions state machine"
  value       = aws_sfn_state_machine.etl_orchestration.arn
}

output "state_machine_name" {
  description = "Name of the Step Functions state machine"
  value       = aws_sfn_state_machine.etl_orchestration.name
}

output "execution_role_arn" {
  description = "ARN of the Step Functions execution role"
  value       = aws_iam_role.step_functions_role.arn
}

output "redshift_policy_arn" {
  description = "ARN of the Redshift Data API policy"
  value       = aws_iam_policy.redshift_data_api.arn
}

output "glue_policy_arn" {
  description = "ARN of the Glue job execution policy"
  value       = aws_iam_policy.glue_job_execution.arn
}