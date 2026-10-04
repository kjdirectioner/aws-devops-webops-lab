variable "vpc_id" {
  type        = string
  description = "The target VPC ID"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for the ALB"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for the EC2 instance"
}

variable "alb_sg_id" {
  type        = string
  description = "Security group ID for the Load Balancer"
}

variable "eice_sg_id" {
  type        = string
  description = "Security group ID for the EC2 Instance Connect Endpoint (EICE)"
}

variable "app_sg_id" {
  type        = string
  description = "Security group ID for the private EC2 application server"
}

variable "ami" {
  type        = string
  description = "The operating system image ID"
}

variable "instance_type" {
  type        = string
  description = "The computing power footprint allocation"
}