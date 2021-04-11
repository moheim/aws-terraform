variable "region" {
  default     = "us-east-1"
  description = "vpc_region"

}
variable "ami" {
  default     = "ami-0742b4e673072066f"
  description = "amazon machine image"

}
variable "instance_type" {
  default     = "t2.micro"
  description = "Type fo instance"

}
variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "vpc cide range"

}
variable "server_port" {
  default     = "80"
  description = "http port"

}
variable "ssh_port" {
  default     = "22"
  description = "ssh port"

}
variable "my_public_ip" {
  default     = "24.55.2.0/24"
  description = "My public ip address"

}
variable "key_pair_name" {
  default     = "myKeyPair"
  description = "ec2-key-pair"

}
variable "access_key" {
    default = ""
  
}
variable "secret_key" {
    default = ""
  
}
variable "public_subnet_1_cidr" {
    default = "10.0.1.0/24"
  description = "Public Subnet 1"

}