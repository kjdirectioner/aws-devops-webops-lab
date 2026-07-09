variable "vpc_cidr" {
    type = string
    description = "CIDR of parent vpc"
}

variable "az_count" { 
    default = 2 
    }