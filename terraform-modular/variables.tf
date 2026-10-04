variable "aws_region" {
  type        = string
  description = "The target AWS region for deployment"
}

variable "vpc_cidr" {
  type        = string
  description = "The primary CIDR block for the custom VPC"
}

variable "ami" {
  type        = string
  description = "The AMI ID for the private Ubuntu EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "The instance sizing for the compute tier"
}

