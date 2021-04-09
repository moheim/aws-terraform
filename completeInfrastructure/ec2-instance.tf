data "aws_instances" "web-app-production-instances" {
  instance_tags = {
    Type = var.tag_webapp
  }
  filter {
    name   = "instance.group-id"
    values = [aws_security_group.ec2_public_security_group.id]
  }

  instance_state_names = [ "running", "stopped" ]
  depends_on           = [aws_autoscaling_group.ec2_public_autoscaling_group]
}

data "aws_instances" "backend-production-instances" {
  instance_tags = {
    Type = var.tag_backend
  }
  filter {
    name   = "instance.group-id"
    values = [aws_security_group.ec2_private_security_group.id]
  }

  instance_state_names = [ "running", "stopped" ]
  depends_on           = [aws_autoscaling_group.ec2_private_autoscaling_group]
}