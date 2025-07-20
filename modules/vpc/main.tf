// Creating a custom VPC with a CIDR block

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

// Creating a public subnet inside that VPC

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidr
  availability_zone = var.availability_zone
  // If this subnet has a route to the internet, go ahead and assign a public IP to any EC2 instance launched here.
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet_name
  }
}


resource "aws_internet_gateway" "igw" {
 
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public_rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.public_rt.id
}