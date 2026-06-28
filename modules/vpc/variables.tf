variable "vpc_cidr" {
    description = "CIDR block for the VPC block"
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