variable "lambda_bucket" {
  description = "Bucket for lambda function"
  type        = string
  default     = "lambda-form-bucket"
}

variable "environment" {
  description = "Lambda environment tag"
  type        = string
  default     = "Dev"
}

variable "lambda_object_key" {
  description = "The name of the lambda object in the S3 bucket"
  type        = string
  default     = "lambda.zip"
}

variable "lambda_object_source" {
  description = "The path to the Lambda Zip file"
  type        = string
  default     = "../lambda/lambda.zip"
}