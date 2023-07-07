output "lambda_function_name" {
  value = aws_lambda_function.process_contact_form.function_name
}

output "lambda_function_invoke_arn" {
  value = aws_lambda_function.process_contact_form.invoke_arn
}

output "lambda_iam_role_arn" {
  value = aws_iam_role.lambda_exec.arn
}