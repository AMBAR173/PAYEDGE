module "vpc" {
    source = "./modules/vpc"
    vpc_cidr = var.vpc_cidr
    region = var.region
    env = var.env
}