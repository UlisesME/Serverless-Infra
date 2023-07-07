resource "aws_api_gateway_rest_api" "contact_form_api" {
  name        = var.api_gateway_name
  description = var.api_gateway_description
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "submit" {
  parent_id   = aws_api_gateway_rest_api.contact_form_api.root_resource_id
  path_part   = var.api_gateway_endpoint
  rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
}

resource "aws_api_gateway_method" "post_submit" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.submit.id
  rest_api_id   = aws_api_gateway_rest_api.contact_form_api.id
}

resource "aws_api_gateway_integration" "lambda_integration" {
  http_method             = aws_api_gateway_method.post_submit.http_method
  resource_id             = aws_api_gateway_resource.submit.id
  rest_api_id             = aws_api_gateway_rest_api.contact_form_api.id
  type                    = "AWS" #lambda integration
  integration_http_method = "POST"

  uri         = var.lambda_function_invoke_arn
  credentials = var.lambda_iam_role_arn
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "api_gw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.contact_form_api.id}/*/${aws_api_gateway_method.post_submit.http_method}${aws_api_gateway_resource.submit.path}"
}

resource "aws_api_gateway_method_response" "api_lambda_response" {
  rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
  resource_id = aws_api_gateway_resource.submit.id
  http_method = aws_api_gateway_method.post_submit.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = [aws_api_gateway_method.post_submit]
}

resource "aws_api_gateway_integration_response" "api_lambda_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.contact_form_api.id
  resource_id = aws_api_gateway_resource.submit.id
  http_method = aws_api_gateway_method.post_submit.http_method
  status_code = aws_api_gateway_method_response.api_lambda_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'${var.static_website_url}'"
  }
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_method_response.api_lambda_response
  ]
}

module "cors" {
  source  = "squidfunk/api-gateway-enable-cors/aws"
  version = "0.3.3"

  api_id          = aws_api_gateway_rest_api.contact_form_api.id
  api_resource_id = aws_api_gateway_resource.submit.id
  allow_methods   = ["OPTIONS", "POST"]
  allow_origin    = var.static_website_url
}

resource "aws_api_gateway_deployment" "dev_deployment" {
  rest_api_id = aws_api_gateway_rest_api.contact_form_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.submit.id,
      aws_api_gateway_method.post_submit.id,
      aws_api_gateway_integration.lambda_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "dev_stage" {
  deployment_id = aws_api_gateway_deployment.dev_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.contact_form_api.id
  stage_name    = var.api_gateway_stage
}

resource "null_resource" "modify_js_file" {
  depends_on = [aws_api_gateway_stage.dev_stage]

  provisioner "local-exec" {
    command = <<-EOF
      sed -i 's#your-api-gateway#${aws_api_gateway_stage.dev_stage.invoke_url}/submit#g' ../website/script.js
    EOF
  }
}

resource "aws_s3_object" "website_objects" {
  depends_on = [null_resource.modify_js_file]
  for_each   = { for file in var.website_files : file => file }

  bucket       = var.static_website_bucket_id
  key          = each.value
  source       = "${var.website_source}${each.value}"
  content_type = each.value == "index.html" ? "text/html" : each.value == "style.css" ? "text/css" : each.value == "script.js" ? "application/javascript" : each.value == "thank-you.html" ? "text/html" : "application/octet-stream"
}