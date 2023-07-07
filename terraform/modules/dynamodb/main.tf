resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = var.table_name
  hash_key       = var.partition_key
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20

  attribute {
    name = var.partition_key
    type = "S"
  }

  tags = {
    Name        = "Contact form dynamodb-table"
    Environment = var.table_environment
  }
}