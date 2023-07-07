output "s3_bucket_id" {
  value = aws_s3_bucket.lambda_bucket.id
}

output "lambda_object_key" {
  value = aws_s3_object.lambda_form_object.key
}

output "lambda_object_source" {
  value = aws_s3_object.lambda_form_object.source
}