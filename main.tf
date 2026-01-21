module "vpc" {
  source = "./vpc"
}

module "sg" {
  source = "./security_group"
  vpc_id = module.vpc.vpc_id
}

module "ec2" {
  source = "./ec2"
  public_subnet_id_01 = module.vpc.public_subnet_id_01
  security_group_id =module.sg.security_group_id
}

module "s3" {
  source = "./s3"
}

module "lambda_policy" {
  source = "./lambda_policy"
  cli_s3_arn = module.s3.cli_s3_arn
  codebuild_arn = module.codebuild.codebuild_arn
  cli_s3_name = module.s3.cli_s3_name
  codebuild_name = module.codebuild.codebuild_name
  codebuild_role_name = module.codebuild.codebuild_role_name
}

module "codebuild" {
  source = "./codebuild"
  cli_s3_arn = module.s3.cli_s3_arn
  cli_s3_name = module.s3.cli_s3_name
}

