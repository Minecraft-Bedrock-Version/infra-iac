variable "project_name" {
  type        = string
  default     = "mbv"
  description = "Project name"
}

variable "region" {
  type        = string
  default     = "ap-northeast-1"
  description = "AWS Region"
}

variable "cli_s3_arn" {
  type        = string
  description = "cli_s3_arn"
}

variable "cli_s3_name" {
  type        = string
  description = "cli_s3_name"
}
