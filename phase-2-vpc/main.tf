################################
# VPC MODULE
################################
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_1_cidr = var.public_subnet_1_cidr
  public_subnet_2_cidr = var.public_subnet_2_cidr
  private_subnet_cidr  = var.private_subnet_cidr
  az_1                 = var.az_1
  az_2                 = var.az_2
}

################################
# SECURITY GROUP MODULE
################################
module "security_group" {
  source = "./modules/security-group"

  vpc_id = module.vpc.vpc_id
  my_ip  = "106.51.217.232" # ⚠️ replace with YOUR public IP (without /32)
}

################################
# EC2 MODULE
################################
module "ec2" {
  source = "./modules/ec2"

  ami_id            = var.ami_id
  instance_type     = var.instance_type
  subnet_id         = module.vpc.public_subnet_1_id
  sg_id             = module.security_group.ec2_sg_id
  key_name          = var.key_name
  target_group_arn  = module.alb.target_group_arn
}

################################
# APPLICATION LOAD BALANCER MODULE
################################
module "alb" {
  source = "./modules/alb"

  vpc_id             = module.vpc.vpc_id
  public_subnet_1_id = module.vpc.public_subnet_1_id
  public_subnet_2_id = module.vpc.public_subnet_2_id
  alb_sg_id          = module.security_group.alb_sg_id
}
