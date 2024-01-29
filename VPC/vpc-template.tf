terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-southeast-2"
}

variable "env-name" {
  type    = string
  default = "tf-test"
}

resource "aws_vpc" "tf-test" {
  cidr_block = "10.192.0.0/16"

  tags = {
    Name = var.env-name
  }
}

resource "aws_internet_gateway" "tf-test" {
  vpc_id = aws_vpc.tf-test.id

  tags = {
    Name = var.env-name
  }
}

resource "aws_subnet" "tf-test-public-1" {
  vpc_id                  = aws_vpc.tf-test.id
  availability_zone       = "ap-southeast-2a"
  cidr_block              = "10.192.10.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env-name}-public-subnet-1"
  }
}

resource "aws_subnet" "tf-test-public-2" {
  vpc_id                  = aws_vpc.tf-test.id
  availability_zone       = "ap-southeast-2b"
  cidr_block              = "10.192.11.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env-name}-public-subnet-2"
  }
}

resource "aws_subnet" "tf-test-public-3" {
  vpc_id                  = aws_vpc.tf-test.id
  availability_zone       = "ap-southeast-2c"
  cidr_block              = "10.192.12.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.env-name}-public-subnet-3"
  }
}

resource "aws_subnet" "tf-test-private-1" {
  vpc_id                  = aws_vpc.tf-test.id
  availability_zone       = "ap-southeast-2a"
  cidr_block              = "10.192.20.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.env-name}-private-subnet-1"
  }
}

resource "aws_subnet" "tf-test-private-2" {
  vpc_id                  = aws_vpc.tf-test.id
  availability_zone       = "ap-southeast-2b"
  cidr_block              = "10.192.21.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.env-name}-private-subnet-2"
  }
}

resource "aws_subnet" "tf-test-private-3" {
  vpc_id                  = aws_vpc.tf-test.id
  availability_zone       = "ap-southeast-2c"
  cidr_block              = "10.192.22.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.env-name}-private-subnet-3"
  }
}

resource "aws_eip" "tf-test-eip-1" {
  domain = "vpc"

  tags = {
    Name = "${var.env-name}-1"
  }
}

resource "aws_eip" "tf-test-eip-2" {
  domain = "vpc"

  tags = {
    Name = "${var.env-name}-2"
  }
}

resource "aws_eip" "tf-test-eip-3" {
  domain = "vpc"

  tags = {
    Name = "${var.env-name}-3"
  }
}

resource "aws_nat_gateway" "tf-test-nat-1" {
  allocation_id = aws_eip.tf-test-eip-1.id
  subnet_id     = aws_subnet.tf-test-public-1.id

  tags = {
    Name = "${var.env-name}-1"
  }
}

resource "aws_nat_gateway" "tf-test-nat-2" {
  allocation_id = aws_eip.tf-test-eip-2.id
  subnet_id     = aws_subnet.tf-test-public-2.id

  tags = {
    Name = "${var.env-name}-2"
  }
}

resource "aws_nat_gateway" "tf-test-nat-3" {
  allocation_id = aws_eip.tf-test-eip-3.id
  subnet_id     = aws_subnet.tf-test-public-3.id

  tags = {
    Name = "${var.env-name}-3"
  }
}

resource "aws_default_route_table" "tf-test" {
  default_route_table_id = aws_vpc.tf-test.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-test.id
  }

  tags = {
    Name = "${var.env-name}-default"
  }
}

resource "aws_route_table_association" "tf-test-public-1" {
  subnet_id      = aws_subnet.tf-test-public-1.id
  route_table_id = aws_default_route_table.tf-test.id
}

resource "aws_route_table_association" "tf-test-public-2" {
  subnet_id      = aws_subnet.tf-test-public-2.id
  route_table_id = aws_default_route_table.tf-test.id
}

resource "aws_route_table_association" "tf-test-public-3" {
  subnet_id      = aws_subnet.tf-test-public-3.id
  route_table_id = aws_default_route_table.tf-test.id
}

resource "aws_route_table" "tf-test-private-1" {
  vpc_id = aws_vpc.tf-test.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.tf-test-nat-1.id
  }
}

resource "aws_route_table" "tf-test-private-2" {
  vpc_id = aws_vpc.tf-test.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.tf-test-nat-2.id
  }
}

resource "aws_route_table" "tf-test-private-3" {
  vpc_id = aws_vpc.tf-test.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.tf-test-nat-3.id
  }
}

resource "aws_route_table_association" "tf-test-private-1" {
  subnet_id      = aws_subnet.tf-test-private-1.id
  route_table_id = aws_route_table.tf-test-private-1.id
}

resource "aws_route_table_association" "tf-test-private-2" {
  subnet_id      = aws_subnet.tf-test-private-2.id
  route_table_id = aws_route_table.tf-test-private-2.id
}

resource "aws_route_table_association" "tf-test-private-3" {
  subnet_id      = aws_subnet.tf-test-private-3.id
  route_table_id = aws_route_table.tf-test-private-3.id
}

resource "aws_security_group" "tf-test" {
  vpc_id      = aws_vpc.tf-test.id
  name        = "no-ingress-sg"
  description = "security group with no ingress rule"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}