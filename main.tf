terraform {
  backend "remote" {
    organization = "Payment-Gateway-DEV"

    workspaces {
      name = "vpc-us-east-1"
    }
  }
}

module "vpc" {
    source = "./modules/vpc"
    vpc_cidr = var.vpc_cidr
    region = var.region
    env = var.env
}