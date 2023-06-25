output "lb-arn" {
  value = aws_lb_target_group.target_group.arn
}
output "prod-lb-dns" {
 value = aws_lb.alb.dns_name
}
output "prod-lb-zone-id" {
 value = aws_lb.alb.zone_id
}