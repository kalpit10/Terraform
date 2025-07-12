terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

// provider is a plugin that knows how to talk to a platform like AWS
// aws tells it which provider plugin to use.
provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "myec2" {
  ami           = "ami-0c02fb55956c7d316" // This one is Amazon Linux 2 image in us-east-1 (free-tier)
  instance_type = var.instance_type // we created a variable with this name

  tags = {
    Name = "MyFirstEC2"
  }
}


