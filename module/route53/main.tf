# # Route 53 and Record 
# data "aws_route53_zone" "route53_zone" {
#   name         = var.domain-name
#   private_zone = false
# }

# #Create route 53 record for stage
# resource "aws_route53_record" "thinkeod-stage"{
#     zone_id = data.aws_route53_zone.route53_zone.id
#     name    = var.domain-name1
#     type    = "A"
#     alias {
#       name     = var.stage_lb_dns_name 
#       zone_id  = var.stage_lb_zoneid 
#       evaluate_target_health = false 
#     }
# }

# #Create route 53 record for prod
# resource "aws_route53_record" "thinkeod-prod"{
#     zone_id = data.aws_route53_zone.route53_zone.id
#     name    = var.domain-name2
#     type    = "A"
#     alias {
#       name     = var.prod_lb_dns_name 
#       zone_id  = var.prod_lb_zoneid
#       evaluate_target_health = false
#     }
# }