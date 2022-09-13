# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc_wordpress"
  }
}

# Subnets
resource "aws_subnet" "public_subnet_web_1a" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"

  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "public_subnet_web_1a"
  }
}

resource "aws_subnet" "public_subnet_web_1b" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"

  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name = "public_subnet_web_1b"
  }
}

resource "aws_subnet" "private_subnet_1a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private_subnet_1a"
  }
}

resource "aws_subnet" "private_subnet_1b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private_subnet_1b"
  }
}

# RDS DB subnet group
resource "aws_db_subnet_group" "subnet_db_group" {
  name       = "db"
  subnet_ids = [aws_subnet.private_subnet_1a.id, aws_subnet.private_subnet_1b.id]

  tags = {
    Name = "subnet_db_group"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}

# EIP NAT Gateways
resource "aws_eip" "eip_ngw_1a" {
  depends_on = [
    aws_route_table_association.public_subnet_web_1a_rtb_assocication
  ]
  vpc = true
}

resource "aws_eip" "eip_ngw_1b" {
  depends_on = [
    aws_route_table_association.public_subnet_web_1b_rtb_assocication
  ]
  vpc = true
}

# NAT Gateways
resource "aws_nat_gateway" "ngw_1a" {
  depends_on = [
    aws_eip.eip_ngw_1a
  ]
  allocation_id = aws_eip.eip_ngw_1a.id
  subnet_id     = aws_subnet.public_subnet_web_1a.id

  tags = {
    Name = "nat_gateway_1a"
  }
}

resource "aws_nat_gateway" "ngw_1b" {
  depends_on = [
    aws_eip.eip_ngw_1a
  ]
  allocation_id = aws_eip.eip_ngw_1b.id
  subnet_id     = aws_subnet.public_subnet_web_1b.id

  tags = {
    Name = "nat_gateway_1b"
  }
}


# Route Table
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rtb"
  }
}

resource "aws_route_table" "ngw_rtb_1a" {
  depends_on = [
    aws_nat_gateway.ngw_1a
  ]
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_1a.id
  }

  tags = {
    Name = "private_rtb_1a"
  }
}

resource "aws_route_table" "ngw_rtb_1b" {
  depends_on = [
    aws_nat_gateway.ngw_1b
  ]
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw_1b.id
  }

  tags = {
    Name = "private_rtb_1b"
  }
}

# Route Association
resource "aws_route_table_association" "public_subnet_web_1a_rtb_assocication" {
  subnet_id      = aws_subnet.public_subnet_web_1a.id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "public_subnet_web_1b_rtb_assocication" {
  subnet_id      = aws_subnet.public_subnet_web_1b.id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "ngw_private_rtb_1a_Association" {
  subnet_id      = aws_subnet.private_subnet_1a.id
  route_table_id = aws_route_table.ngw_rtb_1a.id
}

resource "aws_route_table_association" "ngw_private_rtb_1b_Association" {
  subnet_id      = aws_subnet.private_subnet_1b.id
  route_table_id = aws_route_table.ngw_rtb_1b.id
}