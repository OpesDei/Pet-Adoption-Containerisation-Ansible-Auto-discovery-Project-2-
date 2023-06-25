# Create Launch Template
resource "aws_launch_template" "stage_lt" {
  name_prefix                 = var.stage-lt-name
  image_id                    = var.ami-redhat-id
  instance_type               = var.instance_type
  vpc_security_group_ids      = var.stage-lt-sg
  key_name                    = var.keypair_name
  user_data                   = base64encode(templatefile("${path.root}/module/asg-stage/docker-script.sh", {var1 = var.nexus-ip, var2 = var.nr_key}))
}

#Create AutoScaling Group
resource "aws_autoscaling_group" "stage-asg" {
  name                      = var.stage-asg-name
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 1
  health_check_grace_period = 120
  health_check_type         = "EC2"
  force_delete              = true
  vpc_zone_identifier       = var.vpc-zone-identifier
  target_group_arns         = var.tg-arn
    launch_template {
    id      = aws_launch_template.stage_lt.id
    version = "$Latest"
  }
  tag{
    key                 = "Name"
    value               = "stage-instance"
    propagate_at_launch = true
  }
}

#Create ASG Policy
resource "aws_autoscaling_policy" "asg-policy" {
  name                      =  var.asg-policy
  adjustment_type           = "ChangeInCapacity"
  policy_type               = "TargetTrackingScaling"
  autoscaling_group_name    = aws_autoscaling_group.stage-asg.id
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0
  }
}