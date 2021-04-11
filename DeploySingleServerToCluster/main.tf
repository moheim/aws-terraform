resource "aws_instance" "Web_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = ["${aws_security_group.ec2_public_security_group.id}"]
  subnet_id = aws_subnet.public_subnet_1.id
  associate_public_ip_address = true
  count                  = 3
  key_name               = var.key_pair_name
  tags = {
    "Name" = "Web_server-${count.index}"
  }
  user_data = <<-EOF
	#!/bin/bash
        exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
        /usr/bin/apt-get update
        DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get upgrade -yq
        /usr/bin/apt-get install apache2 -y
        /usr/sbin/ufw allow in "Apache Full"
	/bin/echo "Hello world " >/var/www/html/index.html
        instance_ip=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
        echo $instance_ip >>/var/www/html/index.html
	EOF


}