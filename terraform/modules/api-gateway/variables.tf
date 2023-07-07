variable "api_gateway_name" {
  description = "API Gateway name"
  type        = string
  default     = "ContactFormAPI"
}

variable "api_gateway_description" {
  type    = string
  default = "Contact form API"
}

variable "api_gateway_endpoint" {
  description = "API resource endpoint"
  type        = string
  default     = "submit"
}

variable "api_gateway_stage" {
  type    = string
  default = "dev"
}

variable "region" {
  description = "API Gateway's region"
  type        = string
  default     = "us-east-1"
}

variable "lambda_iam_role_arn" {
  description = "ARN of the IAM role for the Lambda function"
  type        = string
}

variable "lambda_function_invoke_arn" {
  description = "ARN of the Lambda function to be integrated with API Gateway"
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda function name"
  type        = string
}

variable "static_website_url" {
  description = "Static website URL"
  type        = string
}

variable "static_website_bucket_id" {
  description = "Website bucket id"
  type        = string
}

variable "website_source" {
  type    = string
  default = "../website/"
}

variable "website_files" {
  type = list(string)
  default = [
    "index.html",
    "style.css",
    "script.js",
    "thank-you.html"
  ]
}