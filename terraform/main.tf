terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "lambda_function_module" {
  source = "./modules/lambda"
}

module "dynamodb_module" {
  source = "./modules/dynamodb"
}

module "website_module" {
  source = "./modules/s3_static_website"
}

module "api_gateway_module" {
  depends_on                 = [module.website_module]
  source                     = "./modules/api-gateway"
  lambda_iam_role_arn        = module.lambda_function_module.lambda_iam_role_arn
  lambda_function_invoke_arn = module.lambda_function_module.lambda_function_invoke_arn
  lambda_function_name       = module.lambda_function_module.lambda_function_name
  static_website_bucket_id   = module.website_module.static_website_bucket_id
  static_website_url         = module.website_module.website_url
}