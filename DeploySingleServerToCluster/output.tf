output "vpc_id" {
  value = aws_vpc.dev_vpc.id

}
output "vpc_cidr_block" {
  value = aws_vpc.dev_vpc.cidr_block

}
output "ec2_public_security_group_id" {
  value = aws_security_group.ec2_public_security_group.id

}
output "ec2_public_ip" {
  value = ["${aws_instance.Web_server.*.public_ip}"]
}
output "public_subnet_1_id" {
    value = aws_subnet.public_subnet_1.id
  
}