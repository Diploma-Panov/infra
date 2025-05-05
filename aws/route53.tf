resource "aws_route53_record" "api" {
  zone_id = var.route53_zone_id
  name    = "api.urls.mpanov.com"
  type    = "A"

  alias {
    name                   = data.aws_lb.diploma_ingress_alb.dns_name
    zone_id                = data.aws_lb.diploma_ingress_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "root" {
  zone_id = var.route53_zone_id
  name    = "mpanov.com"
  type    = "A"

  alias {
    name                   = data.aws_lb.diploma_ingress_alb.dns_name
    zone_id                = data.aws_lb.diploma_ingress_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cdn" {
  zone_id = var.route53_zone_id
  name    = "cdn.urls.mpanov.com"
  type    = "A"

  alias {
    name                   = module.cloudfront.cloudfront_distribution_domain_name
    zone_id                = module.cloudfront.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}