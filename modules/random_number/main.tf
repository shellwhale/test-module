terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.39.0"
    }
  }
}

variable "name" {
  type    = string
  default = "random_number"
}

resource "aws_iam_role" "random_number" {
  name = var.name
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          },
          "Effect" : "Allow",
          "Sid" : ""
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "insights_policy" {
  role       = aws_iam_role.random_number.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "basic_lambda_execution" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.random_number.id
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.random_number.id
}

resource "aws_iam_role_policy_attachment" "lambda_x_ray_daemon_write_access" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  role       = aws_iam_role.random_number.id
}


# DD_API_KEY_SECRET_ARN	arn:aws:secretsmanager:eu-west-3:007693415291:secret:lca-af-datadog-forwarder-logs-4H4S04
# DD_ENHANCED_METRICS	true
# DD_LOG_LEVEL	INFO
# DD_S3_BUCKET_NAME	lca-af-datadog-forwarder-logs-007693415291
# DD_SERVERLESS_LOGS_ENABLED	true
# DD_SITE	datadoghq.eu
# DD_TAGS	atemi-id:4741,atemi:4741,app-name:mdp,name:random_number,env:nonprod

resource "aws_lambda_function" "random_number" {
  function_name = var.name
  role          = aws_iam_role.random_number.arn

  handler = "index.handler"

  runtime          = "nodejs20.x"
  filename         = data.archive_file.payload.output_path
  source_code_hash = filebase64sha256(data.archive_file.payload.output_path)
  timeout          = 30

  memory_size = 512
}


data "archive_file" "payload" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/payload.zip"
}

data "aws_caller_identity" "current" {}
