resource "aws_subnet" "public_subnet_1" {
    vpc_id = aws_vpc.dev_vpc.id
    cidr_block = var.public_subnet_1_cidr
    availability_zone = "us-east-1a"
    tags = {
      "Name" = "Public Subnet 1 ia 1a"
    }
  
}