variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "vpc cidr block"

}
variable "public_subnet_1_cidr" {
  description = "Public Subnet 1"

}
variable "public_subnet_2_cidr" {
  description = "Public Subnet 2"

}
variable "public_subnet_3_cidr" {
  description = "Public Subnet 3"

}
variable "private_subnet_1_cidr" {
  description = "Private Subnet 1"

}
variable "private_subnet_2_cidr" {
  description = "Private Subnet 2"

}
variable "private_subnet_3_cidr" {
  description = "Private Subnet 3"

}
variable "ec2_instance_type" {
  default = "t2.micro"
  description = "Type of EC2 "
  
}
variable "ec2_key_pair_name" {
  default ="myEC2Keypair"
description = "Keypair to use to connect to Instance"

}
variable "tag_production" {
  default = "Production"
}
variable "tag_webapp" {
  default = "WebApp"
}

variable "tag_backend" {
  default = "Backend"
}