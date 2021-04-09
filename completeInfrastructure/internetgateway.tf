resource "aws_internet_gateway" "production-INGW" {
  vpc_id = aws_vpc.production_vpc.id
  tags = {
    "Name" = "Production internetGW"
  }

}