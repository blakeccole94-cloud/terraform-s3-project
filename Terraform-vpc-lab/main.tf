provider "aws" {
  region = "us-east-1"   # match the region you've been using
}

# The VPC: one /16 network that holds both subnets
resource "aws_vpc" "lab" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "lab-vpc" }
}

# Two subnets carved out of the VPC
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.lab.id
  cidr_block = "10.0.1.0/24"
  tags       = { Name = "lab-public" }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.lab.id
  cidr_block = "10.0.2.0/24"
  tags       = { Name = "lab-private" }
}

# The front door to the internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.lab.id
  tags   = { Name = "lab-igw" }
}

# Public route table: has the 0.0.0.0/0 -> IGW route
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "lab-public-rt" }
}

# Private route table: no routes added (only the automatic local route)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.lab.id
  tags   = { Name = "lab-private-rt" }
}

# Links: which subnet uses which route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.public.id   # THE FLIP (was aws_route_table.private.id)
}