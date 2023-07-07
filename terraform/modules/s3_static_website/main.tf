resource "aws_s3_bucket" "static_website_bucket" {
  bucket = var.static_website_bucket_name

  tags = {
    Name        = "Static Website Bucket"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_ownership_controls" "website_ownership" {
  bucket = aws_s3_bucket.static_website_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "website_access" {
  bucket = aws_s3_bucket.static_website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "website_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.website_ownership,
    aws_s3_bucket_public_access_block.website_access,
  ]

  bucket = aws_s3_bucket.static_website_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "website_configuration" {
  bucket = aws_s3_bucket.static_website_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "website_policies" {
  bucket = aws_s3_bucket.static_website_bucket.id
  policy = data.aws_iam_policy_document.website_bucket_policy.json
}

data "aws_iam_policy_document" "website_bucket_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.static_website_bucket.arn}/*",
    ]
  }
}

data "aws_s3_bucket" "website" {
  bucket = aws_s3_bucket.static_website_bucket.id
}

resource "aws_s3_bucket_cors_configuration" "website_cors_configuration" {
  bucket = aws_s3_bucket.static_website_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["POST"]
    allowed_origins = [data.aws_s3_bucket.website.website_endpoint]
    expose_headers  = []
    max_age_seconds = 3000
  }
}