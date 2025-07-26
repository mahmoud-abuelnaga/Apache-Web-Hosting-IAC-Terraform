# vpc
resource "aws_vpc" "vprofile_vpc" {
  cidr_block = "172.16.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    "Name" = "vprofile-vpc"
  }
}

# internet gateway
resource "aws_internet_gateway" "vprofile_vpc_igw" {
  vpc_id = aws_vpc.vprofile_vpc.id
}

# subnets-1a
resource "aws_subnet" "vprofile_public_subnet_1a" {
  vpc_id = aws_vpc.vprofile_vpc.id
  cidr_block = "172.16.0.0/24"
  map_public_ip_on_launch = true
  availability_zone = var.zones[0]

  tags = {
    "Name" = "vprofile-public-subnet-1a"
  }
}

resource "aws_subnet" "vprofile_private_subnet_1a" {
  vpc_id = aws_vpc.vprofile_vpc.id
  cidr_block = "172.16.1.0/24"
  availability_zone = var.zones[0]

  tags = {
    "Name" = "vprofile-private-subnet-1a"
  }
}

# subnets-1b
resource "aws_subnet" "vprofile_public_subnet_1b" {
  vpc_id = aws_vpc.vprofile_vpc.id
  cidr_block = "172.16.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = var.zones[1]

  tags = {
    "Name" = "vprofile-public-subnet-1b"
  }
}

resource "aws_subnet" "vprofile_private_subnet_1b" {
  vpc_id = aws_vpc.vprofile_vpc.id
  cidr_block = "172.16.3.0/24"
  availability_zone = var.zones[1]

  tags = {
    "Name" = "vprofile-private-subnet-1b"
  }
}

# public route table
resource "aws_route_table" "vprofile_public_subnets_rt" {
  vpc_id = aws_vpc.vprofile_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vprofile_vpc_igw.id
  }

  tags = {
    "Name" = "vprofile-public-subnets-rt"
  }
}

# public route table associations
resource "aws_route_table_association" "vprofile_public_subnet_1a_rt_assoc" {
  subnet_id = aws_subnet.vprofile_public_subnet_1a.id
  route_table_id = aws_route_table.vprofile_public_subnets_rt.id
}

resource "aws_route_table_association" "vprofile_public_subnet_1b_rt_assoc" {
  subnet_id = aws_subnet.vprofile_public_subnet_1b.id
  route_table_id = aws_route_table.vprofile_public_subnets_rt.id
}

# elastic ips
resource "aws_eip" "vprofile_vpc_eips" {
  count = 2
}

# private subnet 1a nat gateway
resource "aws_nat_gateway" "private_subnet_1a_nat_gw" {
  allocation_id = aws_eip.vprofile_vpc_eips[0].id
  subnet_id = aws_subnet.vprofile_public_subnet_1a.id
  
  tags = {
    "Name" = "vprofile-private-subnet-1a-nat-gw"
  }
}

# private subnet 1a route table
resource "aws_route_table" "vprofile_private_subnet_1a_rt" {
  vpc_id = aws_vpc.vprofile_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.private_subnet_1a_nat_gw.id
  }
  
  tags = {
    "key" = "vprofile-private-subnet-1a-rt"
  }
}

resource "aws_route_table_association" "vprofile_private_subnet_1a_rt_assoc" {
  subnet_id = aws_subnet.vprofile_private_subnet_1a.id
  route_table_id = aws_route_table.vprofile_private_subnet_1a_rt.id
}

# private subnet 1b nat gateway
resource "aws_nat_gateway" "private_subnet_1b_nat_gw" {
  allocation_id = aws_eip.vprofile_vpc_eips[1].id
  subnet_id = aws_subnet.vprofile_public_subnet_1b.id
  
  tags = {
    "Name" = "vprofile-private-subnet-1b-nat-gw"
  }
}

# private subnet 1b route table
resource "aws_route_table" "vprofile_private_subnet_1b_rt" {
  vpc_id = aws_vpc.vprofile_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.private_subnet_1b_nat_gw.id
  }

  tags = {
    "Name" = "vprofile-private-subnet-1b-rt"
  }
}

resource "aws_route_table_association" "vprofile_private_subnet_1b_rt_assoc" {
  subnet_id = aws_subnet.vprofile_private_subnet_1b.id
  route_table_id = aws_route_table.vprofile_private_subnet_1b_rt.id
}