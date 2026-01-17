###########################################################################################
######################################## CodeBuild Role ###################################
###########################################################################################

#계정 id 
data "aws_caller_identity" "current" {}
locals {
  account_id = data.aws_caller_identity.current.account_id
}

#codebuild 역할
resource "aws_iam_role" "codebuild_role" {
  name = "${var.project_name}CodebuildRole" #역할 이름

  assume_role_policy = jsonencode({ #ecs에서 사용 가능
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })
}

#고객관리형 정책 생성
resource "aws_iam_policy" "codebuild_policy" {
  name        = "codebuild-policy"
  description = "Codebuild"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Resource = [
          "arn:aws:logs:${var.region}:${local.account_id}:log-group:/aws/codebuild/*"
        ]
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      },
      {
        Effect   = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ]
        Resource = "${var.cli_s3_arn}/*"
      }
    ]
  })
}

#위에서 생성한 정책을 Codebuild 역할에 연결
resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}

###########################################################################################
######################################## Main CodeBuild ###################################
###########################################################################################

#CLI 실행용 Codebuild
resource "aws_codebuild_project" "main_codebuild" {
  name          = "${var.project_name}-codebuild"
  description   = "Codebuild"
  service_role  = aws_iam_role.codebuild_role.arn #위에서 생성한 역할 설정

  artifacts {
    type = "NO_ARTIFACTS" #빌드 후 아티팩트 저장 X
  }

  cache {
    type = "NO_CACHE" #캐시 X
  }

  environment {
    compute_type   = "BUILD_GENERAL1_SMALL" #실행 컴퓨터 크기 -> 3GB, 2vCPU
    image          = "aws/codebuild/standard:5.0" 
    type           = "LINUX_CONTAINER" #리눅스 컨테이너
    image_pull_credentials_type = "CODEBUILD" #codebuild의 기본 이미지 사용
    privileged_mode = true #루트 권한 활성화 -> 빌드를 위해

    environment_variable {
      name  = "S3_BUCKET_NAME"
      value = var.cli_s3_name
    }
  }

  source { #코드를 가져올 곳
    type      = "NO_SOURCE"
    buildspec = <<EOF
version: 0.2

phases:
  pre_build:
    commands:
      - echo "Fetching latest CLI scripts and policy..."
      - aws s3 cp s3://$S3_BUCKET_NAME/$CLI_FILE_NAME ./deploy.sh
      - chmod +x deploy.sh

  build:
    commands:
      - echo "Executing deploy script..."
      - ./deploy.sh

  post_build:
    commands:
      - echo "Deployment Successful"
EOF
  }
}