// Create S3 bucket to upload Lambda function to (currently, bucket is empty so this doesn't matter for now)
resource "aws_s3_bucket" "s3-lambda" {
  bucket = "${var.s3_bucket_name}-in-${var.aws_region}" // bucket name in the environment (declare this in the variables file)

  tags = {
    Name        = "Lambda_Bucket"
    Environment = "Dev"
  }
}


// Zip the lambda function file to be used by AWS.
data "archive_file" "zip_lambda_handler" {
  type        = "zip"
  source_dir  = "${path.module}/lambdaFunc/"
  output_path = "${path.module}/lambdaFunc/lambda_func.zip"
}

resource "aws_lambda_function" "lambda_processor" {
  function_name = "lambda_processor-lambda-function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_handler.handler"
  runtime       = "nodejs14.x"
  filename      = "${path.module}/lambdaFunc/lambda_func.zip"

  timeouts {
    create = "10m"
  }

  depends_on = [
    data.archive_file.zip_lambda_handler,
    aws_s3_bucket.s3-lambda
  ]
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}


resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_processor.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*"
}
