variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami" {
  description = "EC2 Amazon Machine Image"
  type        = string
  default     = "ami-0c02fb55956c7d316"
}

variable "instance_name" {
  description = "EC2 instance name"
  type        = string
  default     = "MyFirstEC2"
}

variable "ssh_allowed_ips" {
  description = "CIDR blocks allowed to SSH"
  type        = list(string) // means it’s a list of CIDR strings like "0.0.0.0/0" or "203.0.113.5/32".
  default     = ["0.0.0.0/0"]
}

variable "instances" {
  description = "Map of instance names to AMIs"
  type        = map(string) // map creates key value
  default = {
    // key = value
    "web1" = "ami-0c02fb55956c7d316"
    "web2" = "ami-0c02fb55956c7d316"
  }
}