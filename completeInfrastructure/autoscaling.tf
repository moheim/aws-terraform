data "aws_ami" "launch_configuration_ami" {
  most_recent = true

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_launch_configuration" "ec2_public_launch_configuration" {
  name_prefix   = "terraform-public-launch-config-"
  image_id      = data.aws_ami.launch_configuration_ami.id
  instance_type = var.ec2_instance_type
  key_name = var.ec2_key_pair_name
  associate_public_ip_address = true
  iam_instance_profile         = aws_iam_instance_profile.ec2_instance_profile.name
  security_groups = [aws_security_group.ec2_public_security_group.id]

  lifecycle {
    create_before_destroy = true
  }
    user_data = <<EOF
    #!/bin/bash
    yum update -y
    yum install httpd -y
    service httpd start
    chkconfig httpd on
    echo "<html><body><h1>Hello Moheim from Production Web instance </h1></body></html>" > /var/www/html/index.html
  EOF
}

resource "aws_autoscaling_group" "ec2_public_autoscaling_group" {
  name                 = "Production-WebApp-AutoScalingGroup"
vpc_zone_identifier   = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id,
    aws_subnet.public_subnet_3.id
  ]
  launch_configuration = aws_launch_configuration.ec2_public_launch_configuration.name
  min_size             = 3
  max_size             = 6
  health_check_type     = "ELB"
  load_balancers        = [aws_elb.webapp-load-balancer.name]

  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = var.tag_production
  }

  tag {
    key                 = "Type"
    propagate_at_launch = true
    value               = var.tag_webapp
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_launch_configuration" "ec2_private_launch_configuration" {
  name_prefix   = "terraform-private-launch-config-"
  image_id      = data.aws_ami.launch_configuration_ami.id
  instance_type = var.ec2_instance_type
  key_name = var.ec2_key_pair_name
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  security_groups = [aws_security_group.ec2_private_security_group.id]

  lifecycle {
    create_before_destroy = true
  }
    user_data = <<EOF
    #!/bin/bash
    yum update -y
    yum install httpd -y
    service httpd start
    chkconfig httpd on
    echo "<html><body><h1>Hello Moheim from Production Backend instance </h1></body></html>" > /var/www/html/index.html
  EOF
}

resource "aws_autoscaling_group" "ec2_private_autoscaling_group" {
  name                 = "Production-Backend-AutoScalingGroup"
vpc_zone_identifier   = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id,
    aws_subnet.private_subnet_3.id
  ]
  launch_configuration = aws_launch_configuration.ec2_private_launch_configuration.name
  min_size             = 3
  max_size             = 6

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "webapp-production-scale-up-policy" {
  autoscaling_group_name   = aws_autoscaling_group.ec2_public_autoscaling_group.name
  name                     = "Production-WebApp-AutoScaling-Policy"
  policy_type              = "TargetTrackingScaling"
  min_adjustment_magnitude = 1

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80.0
  }
}