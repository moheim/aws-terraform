resource "aws_elb" "webapp-load-balancer" {
  name            = "Production-WebApp-LoadBalancer"
  internal        = false
  security_groups = [aws_security_group.ec2_public_security_group.id]
  subnets         = [
      aws_subnet.public_subnet_1.id,
      aws_subnet.public_subnet_2.id,
      aws_subnet.public_subnet_3.id
  ]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  health_check {
    healthy_threshold = 5
    interval = 30
    target = "HTTP:80/index.html"
    timeout = 10
    unhealthy_threshold = 5
  }
}

resource "aws_elb" "backend-load-balancer" {
  name            = "Production-Backend-LoadBalancer"
  internal        = true
  security_groups = [aws_security_group.elb_security_group.id]
  subnets         = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id,
    aws_subnet.private_subnet_3.id
  ]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  health_check {
    healthy_threshold = 5
    interval = 30
    target = "HTTP:80/index.html"
    timeout = 10
    unhealthy_threshold = 5
  }
}