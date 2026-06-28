variable "vpc_cidr" {
    type = string
    description = "CIDR block for VPC"
}

variable "region" {
    type = string
    description = "AWS region"
}

variable "env" {
    type = string
    description = "Enviornment name"
}