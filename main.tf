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
