resource "aws_sns_topic" "webapp-production-autoscaling-alert-topic" {
  display_name = "WebApp-AutoScaling-Topic"
  name         = "WebApp-AutoScaling-Topic"
}

resource "aws_sns_topic_subscription" "webapp_production_autoscaling_sms_subscription" {
  endpoint = "267-471-2126"
  protocol = "sms"
  topic_arn = aws_sns_topic.webapp-production-autoscaling-alert-topic.arn
}

resource "aws_autoscaling_notification" "webapp-autoscaling-notification" {
  group_names   = [aws_autoscaling_group.ec2_public_autoscaling_group.name]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR"
  ]
  topic_arn = aws_sns_topic.webapp-production-autoscaling-alert-topic.arn
}