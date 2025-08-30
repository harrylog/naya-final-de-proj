# modules/stepfunctions/variables.tf
# Input variables for the Step Functions module

variable "step_functions_role_name" {
  description = "Name of the Step Functions execution role"
  type        = string
  default     = "de-proj-step-func-role"
}

variable "state_machine_name" {
  description = "Name of the Step Functions state machine"
  type        = string
  default     = "de-proj-etl-orchestration"
}

variable "redshift_workgroup_arn" {
  description = "ARN of the Redshift workgroup"
  type        = string
}

variable "redshift_workgroup_name" {
  description = "Name of the Redshift workgroup"
  type        = string
}

variable "secrets_policy_arn" {
  description = "ARN of the secrets manager access policy"
  type        = string
}

# Glue job names for orchestration
variable "product_transform_job" {
  description = "Name of the product transformation Glue job"
  type        = string
  default     = "de-proj-product-etl-job"
}

variable "customer_transform_job" {
  description = "Name of the customer transformation Glue job"
  type        = string
  default     = "de-proj-customer-etl-job"
}

variable "orders_transform_job" {
  description = "Name of the orders transformation Glue job"
  type        = string
  default     = "de-proj-orders-etl-job"
}

variable "orderdetails_transform_job" {
  description = "Name of the orderdetails transformation Glue job"
  type        = string
  default     = "de-proj-orderdetails-etl-job"
}

variable "product_load_job" {
  description = "Name of the product loading Glue job"
  type        = string
  default     = "de-proj-load-product-job"
}

variable "customer_load_job" {
  description = "Name of the customer loading Glue job"
  type        = string
 default     = "de-proj0load-customer-job"
 }

variable "orders_load_job" {
  description = "Name of the orders loading Glue job"
  type        = string
  default     = "de-proj-load-order-job"
}

variable "orderdetails_load_job" {
  description = "Name of the orderdetails loading Glue job"
  type        = string
  default     = "de-proj-load-ordersdetails-job"
}

variable "common_tags" {
  description = "Common tags to apply to all Step Functions resources"
  type        = map(string)
  default     = {}
}