#CLI용 s3 버킷 생성
resource "aws_s3_bucket" "cli_s3" {
  bucket = "${var.project_name}-cli-s3" #버킷 이름 지정
}

#CLI용 s3 버킷 버전 관리
resource "aws_s3_bucket_versioning" "cli_s3_versioning" {
  bucket = aws_s3_bucket.cli_s3.id #CLI용 s3 지정
  versioning_configuration {
    status = "Disabled" #버전 관리 비활성화
  }
}

#CLI용 s3 버킷 기본 암호화
resource "aws_s3_bucket_server_side_encryption_configuration" "cli_s3_encryption" {
  bucket = aws_s3_bucket.cli_s3.id #CLI용 s3 지정

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" #SSE-S3 암호화
    }
  }
}

#CLI용 s3 버킷 퍼블릭 액세스 차단 설정
resource "aws_s3_bucket_public_access_block" "cli_s3_public_access" {
  bucket = aws_s3_bucket.cli_s3.id #CLI용 s3 지정

  block_public_acls       = true #모든 퍼블릭 액세스 차단
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}