provider "aws" {
  region     = var.region
  access_key = "AKIAU34G2G6WGIINMICM"
  secret_key = "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"

}
terraform {
  backend "s3" {
    region     = "us-east-1"
    //bucket = "moheim-terraform-remote-state"
    //key = "layer2/backend.tfstate"
    access_key = "AKIAU34G2G6WGIINMICM"
    secret_key = "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"
  }
}
data "terraform_remote_state" "network_configuration" {
  backend = "s3"
  config = {
    bucket = "moheim1-terraform-remote-state"
    key    = "layer1/infrastructure.tfstate"
    region = "us-east-1"
    access_key = "AKIAU34G2G6WGIINMICM"
    secret_key = "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"
  }

}
resource "aws_security_group" "ec2_public_security_group" {
  name        = "EC2-Public-SG"
  description = "Internate reaching access for  EC2 Instance"
  vpc_id      = data.terraform_remote_state.network_configuration.outputs.vpc_id

  ingress  {
    cidr_blocks = ["0.0.0.0/0"]
    description = "MyIngress"
    protocol    = "TCP"
    from_port   = 80
    to_port     = 80
  }

  egress  {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }



}
resource "aws_security_group" "ec2_private_security_group" {
  name        = "EC2-Private-SG"
  description = "Only allowpublic SG to access resource"
  vpc_id      = data.terraform_remote_state.network_configuration.outputs.vpc_id
  ingress  {
    from_port       = 0
    protocol        = "-1"
    to_port         = 0
    security_groups = ["${aws_security_group.ec2_public_security_group.id}"]
  }

  egress  {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }


}


resource "aws_security_group" "elb_security_group" {
  name        = "ELB-SG"
  description = "ELB Security Group"
  vpc_id      = data.terraform_remote_state.network_configuration.outputs.vpc_id
  ingress  {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    description = "Allow all trafic to Load balancer"
  }
  egress  {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

}
resource "aws_iam_role" "ec2_iam_role" {
  name               = "EC2-IAM-Role"
  assume_role_policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement":
  [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["ec2.amazonaws.com", "application-autoscaling.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "ec2_iam_role_policy" {
  name = "EC2-IAM-Policy"
  role = aws_iam_role.ec2_iam_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "elasticloadbalancing:*",
        "cloudwatch:*",
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2-IAM-Instance-Profile"
  role = aws_iam_role.ec2_iam_role.name

}
/*
data "aws_ami" "launch_configuration_ami" {
  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

} */
resource "aws_launch_configuration" "ec2_private_launch_configuration" {
  image_id                    = "ami-0533f2ba8a1995cf9"
  instance_type               = var.ec2_instance_type
  key_name                    = var.key_pair_name
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  security_groups             = ["${aws_security_group.ec2_private_security_group.id}"]
  user_data                   = <<EOF
     #!/bin/bash
     yum update -y
     yum install httpd -y
     service httpd start
     chkconfig httpd on
     export INSTANCE_ID = $(curl http://169.254.169.254/latest/meta-data/instance-id)
     echo "<html><body><h1>Hello from Production Backend at instance <b>"$INSTANCE_ID"</b></h1></body></html>" > /var/www/html/index.html


     EOF

}
resource "aws_launch_configuration" "ec2_public_launch_configuration" {
  image_id                    = "ami-0533f2ba8a1995cf9"
  instance_type               = var.ec2_instance_type
  key_name                    = var.key_pair_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  security_groups             = ["${aws_security_group.ec2_public_security_group.id}"]
  user_data                   = <<EOF
     #!/bin/bash
     yum update -y
     yum install httpd -y
     service httpd start
     chkconfig httpd on
     ecport INSTANCE_ID = $(curl http://169.254.169.254/latest/meta-data/instance-id)
     echo "<html><body><h1>Hello from Production Web app at instance <b>"$INSTANCE_ID"</b></h1></body></html>" > /var/www/html/index.html


     EOF



}
resource "aws_elb" "webapp_load_balancer" {
  name            = "Production-WebApp-LoadBalancer"
  internal        = false
  security_groups = ["${aws_security_group.elb_security_group.id}"]
  subnets = [
    data.terraform_remote_state.network_configuration.outputs.public_subnet_1_id,
    data.terraform_remote_state.network_configuration.outputs.public_subnet_2_id,
    data.terraform_remote_state.network_configuration.outputs.public_subnet_3_id
    ]
  listener {

    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }
  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/index.html"
    interval            = 30
  }

}
resource "aws_elb" "backend_load_balancer" {
  name            = "Production-Backend-LoadBalancer"
  internal        = true
  security_groups = ["${aws_security_group.elb_security_group.id}"]
  subnets = [
    data.terraform_remote_state.network_configuration.outputs.private_subnet_1_id,
    data.terraform_remote_state.network_configuration.outputs.private_subnet_2_id,
    data.terraform_remote_state.network_configuration.outputs.private_subnet_3_id
    ]

  listener {

    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }
  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/index.html"
    interval            = 30
  }

}
resource "aws_autoscaling_group" "ec2_private_autoscaling_group" {
  name = "Production-Backend-AutoScalingGroup"
  vpc_zone_identifier = [
    data.terraform_remote_state.network_configuration.outputs.private_subnet_1_id,
    data.terraform_remote_state.network_configuration.outputs.private_subnet_2_id,
    data.terraform_remote_state.network_configuration.outputs.private_subnet_3_id
  ]
  max_size             = var.max_instance_size
  min_size             = var.min_instance_size
  launch_configuration = aws_launch_configuration.ec2_private_launch_configuration.name
  health_check_type    = "ELB"
  load_balancers       = ["${aws_elb.backend_load_balancer.name}"]
  tag {
    key                 = "Name"
    propagate_at_launch = false
    value               = "Backend-EC2-Instance"
  }
  tag {
    key                 = "Type"
    propagate_at_launch = false
    value               = "Production"
  }


}
resource "aws_autoscaling_group" "ec2_public_autoscaling_group" {
  name = "Production-WebApp-AutoScalingGroup"
  vpc_zone_identifier = [
    data.terraform_remote_state.network_configuration.outputs.public_subnet_1_id,
    data.terraform_remote_state.network_configuration.outputs.public_subnet_2_id,
    data.terraform_remote_state.network_configuration.outputs.public_subnet_3_id
  ]
  max_size             = var.max_instance_size
  min_size             = var.min_instance_size
  launch_configuration = aws_launch_configuration.ec2_public_launch_configuration.name
  health_check_type    = "ELB"
  load_balancers       = ["${aws_elb.webapp_load_balancer.name}"]
  tag {
    key                 = "Name"
    propagate_at_launch = false
    value               = "WebApp-EC2-Instance"
  }
  tag {
    key                 = "Type"
    propagate_at_launch = false
    value               = "WebApp"
  }


}
resource "aws_autoscaling_policy" "webapp_production_scaling_policy" {
  autoscaling_group_name   = aws_autoscaling_group.ec2_public_autoscaling_group.name
  name                     = "Production-WebAPP-AutoScaling-Policy"
  policy_type              = "TargetTrackingScaling"
  min_adjustment_magnitude = 1

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80.0
  }
}

resource "aws_autoscaling_policy" "backend_production_scaling_policy" {
  autoscaling_group_name   = aws_autoscaling_group.ec2_private_autoscaling_group.name
  name                     = "Production-Backend-AutoScaling-Policy"
  policy_type              = "TargetTrackingScaling"
  min_adjustment_magnitude = 1

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80.0
  }
}
resource "aws_sns_topic" "webapp_production_autoscaling_alert_topic" {
  display_name = "WebApp-AutoScaling-Topic"
  name         = "WebApp-AutoScaling-Topic"

}
resource "aws_sns_topic_subscription" "webapp_production_autoscaling_sms_subscription" {
  endpoint  = "+12674712126"
  topic_arn = aws_sns_topic.webapp_production_autoscaling_alert_topic.arn
  protocol  = "sms"

}
resource "aws_autoscaling_notification" "webapp-autoscaling-notification" {
  group_names   = [aws_autoscaling_group.ec2_public_autoscaling_group.name]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR"
  ]
  topic_arn = aws_sns_topic.webapp_production_autoscaling_alert_topic.arn
}