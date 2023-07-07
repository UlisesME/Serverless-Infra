output "website_url" {
  value = "http://${data.aws_s3_bucket.website.website_endpoint}"
}

output "static_website_bucket_id" {
  value = aws_s3_bucket.static_website_bucket.id
}