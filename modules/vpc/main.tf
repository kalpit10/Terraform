// ---------------------- VPC SECTION---------------------------------------
// Creating a custom VPC with a CIDR block
resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

// ------------------SUBNETS SECTION-------------------------
// Creating a public subnet inside that VPC

resource "aws_subnet" "my_public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet_cidr
  availability_zone = var.availability_zone
  // If this subnet has a route to the internet, go ahead and assign a public IP to any EC2 instance launched here.
  map_public_ip_on_launch = true

  tags = {
    Name = var.subnet_name
  }
}


resource "aws_subnet" "my_private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.private_az
  // This is a private subnet, so now IPv4 allocation for EC2
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}-private-subnet"
  }
}


// ------------------EIP SECTION-------------------

resource "aws_eip" "nat_eip" {
  # This tells AWS that the EIP is meant to be used inside a VPC, not with EC2-Classic (older). 
  # This is required when attaching EIP to a NAT Gateway.
  domain = "vpc"

  tags = {
    Name = "${var.vpc_name}-nat-eip"
  }
}

// _------------------------IGW-----------------------------
resource "aws_internet_gateway" "igw" {

  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.vpc_name}-igw"
  }
}


// -------------------- NATGW SECTION-----------------------------

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  // NATGW always remains in a public subnet
  subnet_id = aws_subnet.my_public_subnet.id

  tags = {
    Name = "${var.vpc_name}-nat-gw"
  }

  # ensure IGW exists before NAT GW
  depends_on = [aws_internet_gateway.igw]
}


// ------------------------RT SECTION------------------------
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
  subnet_id      = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}

// Associate Private Subnet with the Private Route Table
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.my_private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}