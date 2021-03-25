provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAWJ36C65V6WLCCVPK"
  secret_key = "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"
}
resource "aws_instance" "myfirstec2"{
    ami = "ami-0533f2ba8a1995cf9"
    instance_type = "t2.micro"
    tags = {
      "key" = "myfirstec2"
    }
}