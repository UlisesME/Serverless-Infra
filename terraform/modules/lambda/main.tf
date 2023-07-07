module "s3_lambda_module" {
  source = "../s3_lambda"
}

resource "aws_lambda_function" "process_contact_form" {
  function_name = var.function_name

  s3_bucket = module.s3_lambda_module.s3_bucket_id
  s3_key    = module.s3_lambda_module.lambda_object_key

  runtime = "nodejs18.x"
  handler = "index.handler"

  source_code_hash = filebase64sha256(module.s3_lambda_module.lambda_object_source)

  role = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "process_contact_form" {
  name = "/aws/lambda/${aws_lambda_function.process_contact_form.function_name}"

  retention_in_days = var.retention_in_days
}

resource "aws_iam_role" "lambda_exec" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}
