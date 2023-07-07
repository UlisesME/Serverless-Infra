variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "ProcessContactForm"
}

variable "retention_in_days" {
  description = "Retention period for CloudWatch logs"
  type        = number
  default     = 30
}

variable "iam_role_name" {
  description = "Name of the IAM role for Lambda execution"
  type        = string
  default     = "serverless_lambda_form_role"
}