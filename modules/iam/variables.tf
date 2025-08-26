# modules/iam/variables.tf
# Input variables for the IAM module

variable "s3_policy_name" {
  description = "Name of the S3 access policy"
  type        = string
  default     = "naya-de-proj-s3-policy"
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket to grant access to"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all IAM resources"
  type        = map(string)
  default     = {}
}