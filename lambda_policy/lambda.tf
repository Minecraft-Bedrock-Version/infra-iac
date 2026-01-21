# Lambda 역할 생성
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}LambdaRole" #역할 이름

  assume_role_policy = jsonencode({ #lambda에서 사용 가능
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

#계정 ID 가져오기
# data "aws_caller_identity" "current" {}
# locals {
#   account_id = data.aws_caller_identity.current.account_id
# }

#고객관리형 정책 생성
resource "aws_iam_policy" "lambda_policy" {
  name   = "${var.project_name}-lambda-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow"
        Action    = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject"
        ]
        Resource  = "${var.cli_s3_arn}"
      },
      {
        Effect    = "Allow"
        Action    = [
            "codebuild:StartBuild",
            "codebuild:BatchGetBuilds"
        ],
        Resource  = "${var.codebuild_arn}"
      },
      {
        Effect = "Allow"
        Action = [
            "iam:AttachRolePolicy",
            "iam:DetachRolePolicy",
            "iam:CreatePolicy",
            "iam:DeletePolicy",
            "iam:GetPolicy"
        ],
        Resource = "*"
      }
    #   {
    #     Effect    = "Allow"
    #     Action    = [
    #       "logs:CreateLogGroup",
    #       "logs:CreateLogStream",
    #       "logs:PutLogEvents"
    #     ]
    #     Resource  = "arn:aws:logs:${var.aws_region}:${local.account_id}:log-group:/aws/lambda/*"
    #   }
    ]
  })
}

#위에서 생성한 정책을 Lambda 역할에 연결
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

#lambda 함수 생성
resource "aws_lambda_function" "lambda" {
  filename      = "./lambda_policy/lambda.zip"
  function_name = "${var.project_name}_Codebuild_Lambda"
  role          = aws_iam_role.lambda_role.arn
  runtime       = var.lambda_language
  timeout       = var.lambda_timeout
  handler       = "lambda.lambda_handler"
  architectures = ["x86_64"]

  source_code_hash = filebase64sha256("./lambda_policy/lambda.zip") 

  environment {
    variables = {
      S3_BUCKET_NAME = var.cli_s3_name
      CODEBUILD_PROJECT_NAME = var.codebuild_name
      CODEBUILD_ROLE_NAME = var.codebuild_role_name
    }
  }
}