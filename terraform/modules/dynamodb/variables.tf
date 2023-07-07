variable "table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "ContactFormEntries"
}

variable "partition_key" {
  type    = string
  default = "SubmissionId"
}

variable "table_environment" {
  type    = string
  default = "Dev"
}