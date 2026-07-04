variable "vpc_cidr" {
    description = "CIDRR block for the VPC bblock"
    type = string
}

variable "region" {
    description = "aws region"
    type = string
}

variable "env" {
    description = "This variable for enviornment"
    type = string
}