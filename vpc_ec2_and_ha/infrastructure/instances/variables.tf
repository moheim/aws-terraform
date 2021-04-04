variable "region" {
  default     = "us-east-1"
  description = "AWS Region"

}
variable "remote_state_bucket" {
  description = "Bucket name for layer1 remote state"

}
variable "remote_state_key" {
  default     = "layer1/infrastructure.tfstate"
  description = "Remote state file to read"
}
variable "ec2_instance_type" {
  description = "EC2 Inatance type to launch"

}
variable "key_pair_name" {
  default     = "myEC2Keypair"
  description = "Keypair to use to connect to Instance"

}
variable "max_instance_size" {
  description = "Maximum number of instances to launch"

}
variable "min_instance_size" {
  description = "Minimum number of instances to launch"

}