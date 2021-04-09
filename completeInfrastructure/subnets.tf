resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.production_vpc.id
  cidr_block        = var.public_subnet_1_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public Subnet 1 in 1a"
  }
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.production_vpc.id
  cidr_block        = var.public_subnet_2_cidr
  availability_zone = "us-east-1b"

  tags = {
    Name = "Public Subnet 2 in 1b"
  }
}
resource "aws_subnet" "public_subnet_3" {
  vpc_id            = aws_vpc.production_vpc.id
  cidr_block        = var.public_subnet_3_cidr
  availability_zone = "us-east-1c"

  tags = {
    Name = "Public Subnet 3 in 1c"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.production_vpc.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private Subnet 1 in 1a"
  }
}
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.production_vpc.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private Subnet 2 in 1b"
  }
}
resource "aws_subnet" "private_subnet_3" {
  vpc_id            = aws_vpc.production_vpc.id
  cidr_block        = var.private_subnet_3_cidr
  availability_zone = "us-east-1c"

  tags = {
    Name = "Private Subnet 3 in 1c"
  }
}
