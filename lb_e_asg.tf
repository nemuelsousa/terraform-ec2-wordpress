# ELB
resource "aws_lb" "elb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.elb.id
  ]
  subnets = [
    aws_subnet.public_subnet_web_1a.id,
    aws_subnet.public_subnet_web_1b.id
  ]
}

# ELB Listener
resource "aws_lb_listener" "elb_http_wordpress" {
  load_balancer_arn = aws_lb.elb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.ec2_http_wordpress.arn
    type             = "forward"
  }
}

# ELB Target Group
resource "aws_lb_target_group" "ec2_http_wordpress" {
  name     = "alb-tg-http"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    interval            = 10
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  stickiness {
    cookie_duration = 1800
    enabled         = true
    type            = "lb_cookie"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "ec2_asg_wordpress" {
  name                      = "asg_wordpress"
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 2

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]

  metrics_granularity = "1Minute"

  vpc_zone_identifier = [
    aws_subnet.private_subnet_1a.id,
    aws_subnet.private_subnet_1b.id
  ]

  launch_template {
    id      = aws_launch_template.ec2_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.ec2_http_wordpress.arn]
}

# Auto Scaling Group Policy
resource "aws_autoscaling_policy" "policy_up" {
  name                   = "policy_up"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ec2_asg_wordpress.name
}

resource "aws_autoscaling_policy" "policy_down" {
  name                   = "policy_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.ec2_asg_wordpress.name
}

# CloudWatch Alarm Scaling UP
resource "aws_cloudwatch_metric_alarm" "cpu_alarm_up" {
  alarm_name          = "cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ec2_asg_wordpress.name
  }

  alarm_description = "EC2 CPU Utilization Up"
  alarm_actions     = [aws_autoscaling_policy.policy_up.arn]
}

# CloudWatch Alarm Scaling Down
resource "aws_cloudwatch_metric_alarm" "cpu_alarm_down" {
  alarm_name          = "cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.ec2_asg_wordpress.name
  }

  alarm_description = "EC2 CPU Utilization Down"
  alarm_actions     = [aws_autoscaling_policy.policy_down.arn]
}