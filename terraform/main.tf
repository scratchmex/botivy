###################
# Lambda function
###################
resource "aws_iam_role" "lambda" {
  name_prefix = var.function_name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  description = "My awesome lambda function from container image by terraform"

  role = aws_iam_role.lambda.arn

  ##################
  # Container Image
  ##################
  image_uri    = docker_registry_image.app.name
  package_type = "Image"

  ##############
  # Env. vars.
  ##############
  environment {
    variables = {
      GITHUB_TOKEN = var.GITHUB_TOKEN
      GITHUB_REPO = var.GITHUB_REPO
    }
  }
}

###############
# API Gateway
###############
resource "aws_apigatewayv2_api" "this" {
  name = "${var.function_name}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "this" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "AWS_PROXY"
  payload_format_version = "2.0"

  integration_method = "POST"
  integration_uri = aws_lambda_function.this.invoke_arn
}

resource "aws_apigatewayv2_route" "this" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /"

  # doc: https://github.com/hashicorp/terraform-provider-aws/issues/12972
  target = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.this.id
  name   = "$default"

  auto_deploy = true
}

resource "aws_lambda_permission" "this" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = format("arn:aws:execute-api:%v:%v:%v/*/*/", var.region, data.aws_caller_identity.this.account_id, aws_apigatewayv2_api.this.id)
}

#################
# ECR Repository
#################
resource "aws_ecr_repository" "this" {
  name = var.function_name
}

###############################################
# Create Docker Image and push to ECR registry
###############################################
resource "docker_registry_image" "app" {
  name = local.ecr_image

  build {
    context = "../"
  }
}
