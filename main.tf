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

// --------EC2 Instances----------------

resource "aws_instance" "myec2" {
  ami           = var.ami           // This one is Amazon Linux 2 image in us-east-1 (free-tier)
  instance_type = var.instance_type // we created a variable with this name

  vpc_security_group_ids = [aws_security_group.my_sg.id] // Attach this EC2 to the security group we just created.

  tags = {
    Name = var.instance_name
  }
}

// ----------Security Groups----------------

resource "aws_security_group" "my_sg" {
  //----- Inbound Rule for SSH-------
  ingress {
    from_port   = 22 // range of ports to allow (just 22 here, for SSH).
    to_port     = 22
    protocol    = "tcp"               // (SSH runs on TCP).
    cidr_blocks = var.ssh_allowed_ips // means allow from any IP on the internet.
  }

  //---------Inbound Rule for HTTP-----------  
  ingress {
    from_port   = 80 // 80 → allows HTTP traffic.
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1 // Allow all outbound traffic on all protocols (-1 is AWS code for "all").
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MySecurityGroup"
  }
}


// ---------EIP Block---------------

resource "aws_eip" "my_eip" {
  instance = aws_instance.myec2.id // Tells AWS to associate this EIP with your EC2 instance.
  
  tags = {
    Name = "MyElasticIP"
  }
}