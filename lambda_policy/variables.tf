variable "project_name" {
  type        = string
  default     = "mbv"
  description = "Project name"
}

variable "lambda_language" {
  type        = string
  default     = "python3.9"
  description = "Lambda Language"
}

variable "lambda_timeout" {
  type        = number
  default     = 900
  description = "Lambda Timeout"
}

variable "cli_s3_arn" {
  type        = string
  description = "cli_s3_arn"
}

variable "codebuild_arn" {
  type        = string
  description = "codebuild_arn"
}

variable "cli_s3_name" {
  type        = string
  description = "cli_s3_name"
}

variable "codebuild_name" {
  type        = string
  description = "codebuild_name"
}

variable "codebuild_role_name" {
  type        = string
  description = "codebuild_role_name"
}