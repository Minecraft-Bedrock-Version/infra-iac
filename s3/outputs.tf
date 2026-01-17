output "cli_s3_name" {
  value       = aws_s3_bucket.cli_s3.bucket
  description = "CLI S3 bucket Name"
}

output "cli_s3_id" {
  value       = aws_s3_bucket.cli_s3.id
  description = "CLI S3 bucket ID"
}

output "cli_s3_arn" {
  value       = aws_s3_bucket.cli_s3.arn
  description = "CLI S3 bucket ARN"
}