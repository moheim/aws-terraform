resource "aws_eip" "elastic-ip-for-NGW" {
  vpc                       = true
  associate_with_private_ip = "10.0.0.10"
  tags = {
    "Name" = "Production_EIP"
  }
}
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.elastic-ip-for-NGW.id
  subnet_id     = aws_subnet.public_subnet_1.id

  tags = {
    Name = "Production-Nat-GW"
  }
  depends_on = [aws_eip.elastic-ip-for-NGW]
}