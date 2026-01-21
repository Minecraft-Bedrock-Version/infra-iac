output "lambda_arn" { 
  value       = aws_lambda_function.lambda.arn
  description = "Lambda ARN"
}

output "lambda_role_arn" { 
  value       = aws_iam_role.lambda_role.arn
  description = "Lambda Role ARN"
}

output "lambda_role_name" { 
  value       = aws_iam_role.lambda_role.name
  description = "Lambda Role name"
}

output "lambda_policy_arn" { 
  value       = aws_iam_policy.lambda_policy.arn
  description = "Lambda Policy arn"
}

output "lambda_function_name" { 
  value       = aws_lambda_function.lambda.function_name
  description = "lambda_function_name"
}