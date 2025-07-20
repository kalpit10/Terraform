// These are input values we expect from the root module:

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "subnet_name" {
  description = "Name tag for the subnet"
  type        = string
}

variable "availability_zone" {
  description = "AZ for the subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR for private subnet 1"
  type        = string
}

variable "private_az" {
  description = "AZ for the private subnet"
  type        = string
}
