terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  // Telling terraform to access this bucket to store our tfstate file remotely
  // If we are creating the backend for the first time, we have to rerun terraform init
  backend "s3" {
    bucket = "kalpit-terraform-state-2025"
    key    = "global/s3/terraform.tfstate" // the file path inside the bucket. You can organize like folders.
    region = "us-east-1"
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

// ---------------VPC BLOCK--------------------

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr            = "10.0.0.0/16"
  vpc_name            = "Kalpit-VPC"
  subnet_cidr         = "10.0.1.0/24"
  private_subnet_cidr = "10.0.2.0/24"
  subnet_name         = "Kalpit-Subnet"
  availability_zone   = "us-east-1a"
  private_az          = "us-east-1b"
}


// --------EC2 Instances via Module----------------
// Instead of creating EC2 + SG directly here, we moved it into a reusable module.
// Now we just call the module and pass the needed variables.


// "myservers" is name for using the module
module "myservers" {
  for_each = var.instances // loops over the map we defined.

  source = "./modules/ec2_instance"

  ami             = each.value // the AMI ID from the map.
  instance_type   = var.instance_type
  instance_name   = "${local.instance_name_prefix}-${each.key}" // will create names like MyProject-web1
  vpc_id          = module.vpc.vpc_id
  subnet_id       = module.vpc.subnet_id
  ssh_allowed_ips = var.ssh_allowed_ips
}



// ---------EIP Block---------------
// This will attach an Elastic IP to each instance created via the module.
// We have to use module output to get the instance ID.

resource "aws_eip" "my_eip" {
  for_each = var.instances

  // AWS will attach the EIP to the EC2 instance ID returned by the module output
  instance = module.myservers[each.key].instance_id

  tags = {
    Name = "${local.instance_name_prefix}-eip-${each.key}"
  }

  // Do not even try creating EIPs until all instances exist
  depends_on = [module.myservers]
}
