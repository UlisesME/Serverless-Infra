output "api_gateway_id" {
  value = aws_api_gateway_rest_api.contact_form_api.id
}

output "api_gateway_resource_id" {
  value = aws_api_gateway_resource.submit.id
}

output "api_gateway_invoke_url" {
  value = aws_api_gateway_deployment.dev_deployment.invoke_url
}