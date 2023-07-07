resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.lambda_bucket

  tags = {
    Name        = "Lambda form bucket"
    Environment = var.environment
  }
}

resource "aws_s3_object" "lambda_form_object" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = var.lambda_object_key
  source = var.lambda_object_source

  etag = filemd5(var.lambda_object_source)
}