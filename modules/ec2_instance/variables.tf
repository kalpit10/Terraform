// These are like function parameters — no values assigned here.

variable "ami" {}
variable "instance_type" {}
variable "instance_name" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "ssh_allowed_ips" {
  type = list(string)
}
