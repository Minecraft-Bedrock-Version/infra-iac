output "ec2_role_arn" { 
  value       = aws_iam_role.ec2_role.arn
  description = "EC2 Role ARN"
}

output "ec2_role_name" { 
  value       = aws_iam_role.ec2_role.name
  description = "EC2 Role name"
}

output "ec2_policy_arn" { 
  value       = aws_iam_policy.ec2_policy.arn
  description = "EC2 Policy ARN"
}

output "ec2_instance_id" {
  value       = aws_instance.mbv.id
  description = "Instance id"
}

output "ec2_public_ip" {
  value       = aws_eip.ec2_eip.public_ip
  description = "Public IP"
}

output "eip_ec2_association" {
  value       = aws_eip.ec2_eip.id
  description = "EIP EC2 Association"
}

output "ec2_instance_profile_name" {
  value       = aws_iam_instance_profile.mbv_profile.name
  description = "ec2_instance_profile_name"
}