provider "aws" {
  region     = var.region
  access_key = ""
  secret_key = "/"

}
terraform {
  backend "s3" {
    region     = "us-east-1"
    access_key = ""
    secret_key = "/"
  }
}
resource "aws_vpc" "production-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "production-vpc"
  }
}
resource "aws_subnet" "public-subnet-1" {
  cidr_block        = var.public_subnet_1_cidr
  vpc_id            = aws_vpc.production-vpc.id
  availability_zone = "us-east-1a"
  tags = {
    "Name" = "Public-Subnet-1"
  }

}

resource "aws_subnet" "public-subnet-2" {
  cidr_block        = var.public_subnet_2_cidr
  vpc_id            = aws_vpc.production-vpc.id
  availability_zone = "us-east-1b"
  tags = {
    "Name" = "Public-Subnet-2"
  }

}
resource "aws_subnet" "public-subnet-3" {
  cidr_block        = var.public_subnet_3_cidr
  vpc_id            = aws_vpc.production-vpc.id
  availability_zone = "us-east-1c"
  tags = {
    "Name" = "Public-Subnet-3"
  }

}
resource "aws_subnet" "private-subnet-1" {
  cidr_block        = var.private_subnet_1_cidr
  vpc_id            = aws_vpc.production-vpc.id
  availability_zone = "us-east-1a"
  tags = {
    "Name" = "Private-subnet-1"
  }

}
resource "aws_subnet" "private-subnet-2" {
  cidr_block        = var.private_subnet_2_cidr
  vpc_id            = aws_vpc.production-vpc.id
  availability_zone = "us-east-1b"
  tags = {
    "Name" = "Private-Subnet-2"
  }

}
resource "aws_subnet" "private-subnet-3" {
  cidr_block        = var.private_subnet_3_cidr
  vpc_id            = aws_vpc.production-vpc.id
  availability_zone = "us-east-1c"
  tags = {
    "Name" = "Private-Subnet-3"
  }

}
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.production-vpc.id
  tags = {
    "Name" = "Public-Rout-Table"
  }

}
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.production-vpc.id
  tags = {
    "Name" = "Private-Route-Table"
  }
}
resource "aws_route_table_association" "public-subnet-1-association" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-route-table.id
}
resource "aws_route_table_association" "public-subnet-2-association" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public-route-table.id
}
resource "aws_route_table_association" "public-subnet-3-association" {
  subnet_id      = aws_subnet.public-subnet-3.id
  route_table_id = aws_route_table.public-route-table.id
}
resource "aws_route_table_association" "private-subnet-1-association" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private-route-table.id
}
resource "aws_route_table_association" "private-subnet-2-association" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private-route-table.id
}
resource "aws_route_table_association" "private-subnet-3-association" {
  subnet_id      = aws_subnet.private-subnet-3.id
  route_table_id = aws_route_table.private-route-table.id
}
resource "aws_eip" "elastic-ip-for-NGW" {
  vpc                       = true
  associate_with_private_ip = "10.0.0.5"
  tags = {
    "Name" = "Production_EIP"
  }
}
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.elastic-ip-for-NGW.id
  subnet_id     = aws_subnet.public-subnet-1.id
  tags = {
    "Name" = "Production-Nat-GW"
  }
  depends_on = ["aws_eip.elastic-ip-for-NGW"

  ]


}
resource "aws_route" "nat_gw_route" {
  route_table_id         = aws_route_table.private-route-table.id
  nat_gateway_id         = aws_nat_gateway.nat-gw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_internet_gateway" "production-ing" {
  vpc_id = aws_vpc.production-vpc.id
  tags = {
    "Name" = "Production-IGW"
  }

}
resource "aws_route" "public-internat-gw-route" {
  route_table_id         = aws_route_table.public-route-table.id
  gateway_id             = aws_internet_gateway.production-ing.id
  destination_cidr_block = "0.0.0.0/0"
}
