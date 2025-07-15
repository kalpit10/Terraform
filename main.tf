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

// It is a block where we can define one or many named local values. DRY (dont repeat yourself code)
locals {
  instance_name_prefix = "MyProject"
}

// Telling terraform to access this bucket to store our tfstate file remotely
// If we are creating the backend for the first time, we have to rerun terraform init
terraform {
  backend "s3" {
    bucket = "kalpit-terraform-state-2025"
    key    = "global/s3/terraform.tfstate" // the file path inside the bucket. You can organize like folders.
    region = "us-east-1"
  }
}

// --------EC2 Instances----------------

# resource "aws_instance" "myec2" {
#   count         = 2                 // tells Terraform to create 2 EC2 instances.
#   ami           = var.ami           // This one is Amazon Linux 2 image in us-east-1 (free-tier)
#   instance_type = var.instance_type // we created a variable with this name

#   vpc_security_group_ids = [aws_security_group.my_sg.id] // Attach this EC2 to the security group we just created.

#   tags = {
#     Name = "${var.instance_name}-${count.index}" // ${count.index} is 0 for the first, 1 for the second — this gives names like MyFirstEC2-0 and MyFirstEC2-1.
#   }
# }


resource "aws_instance" "myec2" {
  for_each = var.instances //  loops over the map we defined.

  ami                    = each.value // the AMI ID.
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = {
    Name = "${local.instance_name_prefix}-${each.key}" // "MyProject-web1", "MyProject-web2"
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
  for_each = var.instances
  # count = 2
  // aws_eip.my_eip[0] attaches to aws_instance.myec2[0]
  // aws_eip.my_eip[1] attaches to aws_instance.myec2[1]
  // instance = aws_instance.myec2[count.index].id // Tells AWS to associate this EIP with your EC2 instance.

  instance = aws_instance.myec2[each.key].id // AWS will attach the key in myec2 object, which is web1 and web2

  tags = {
    Name = "${local.instance_name_prefix}-eip-${each.key}"
  }
  // Do not even try creating EIPs until all instances exist
  depends_on = [aws_instance.myec2]
}