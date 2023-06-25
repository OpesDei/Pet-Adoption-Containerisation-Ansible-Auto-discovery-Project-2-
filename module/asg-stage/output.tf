output "Stage-ASG-id" {
  value = aws_autoscaling_group.stage-asg.id
}

output "Stage-ASG-name" {
  value = aws_autoscaling_group.stage-asg.name
}

output "Stage-LT-id" {
  value = aws_launch_template.stage_lt.image_id
}