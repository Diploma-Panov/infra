module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"

  aliases = ["cdn.urls.mpanov.com"]

  # ordered_cache_behavior = [
  #   {
  #     path_pattern           = "/api/*"
  #     target_origin_id       = "alb"
  #     viewer_protocol_policy = "redirect-to-https"
  #     allowed_methods        = ["GET","HEAD","OPTIONS","PUT","PATCH","POST","DELETE"]
  #     cached_methods         = ["GET","HEAD"]
  #     forwarded_values = {
  #       query_string = true
  #       cookies = { forward = "all" }
  #     }
  #     min_ttl     = 0
  #     default_ttl = 60
  #     max_ttl     = 86400
  #   },
  #   {
  #     path_pattern           = "/r/*"
  #     target_origin_id       = "alb"
  #     viewer_protocol_policy = "redirect-to-https"
  #     allowed_methods        = ["GET","HEAD","OPTIONS","PUT","PATCH","POST","DELETE"]
  #     cached_methods         = ["GET","HEAD"]
  #     forwarded_values = {
  #       query_string = true
  #       cookies = { forward = "all" }
  #     }
  #     min_ttl     = 0
  #     default_ttl = 60
  #     max_ttl     = 86400
  #   }
  # ]

  default_cache_behavior = {
    target_origin_id       = "s3"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET","HEAD","OPTIONS"]
    cached_methods         = ["GET","HEAD"]
    forwarded_values = {
      query_string = false
      cookies = { forward = "none" }
    }
  }

  origin = {
    # alb = {
    #   domain_name = module.alb.lb_dns_name
    #   origin_id   = "alb"
    #   custom_origin_config = {
    #     http_port              = 80
    #     https_port             = 443
    #     origin_protocol_policy = "https-only"
    #     origin_ssl_protocols   = ["TLSv1.2"]
    #   }
    # },
    s3 = {
      domain_name = aws_s3_bucket.auth_service_images.bucket_regional_domain_name
      origin_id   = "s3"
      s3_origin_config = {
        cloudfront_access_identity_path = aws_cloudfront_origin_access_identity.s3_oai.cloudfront_access_identity_path
      }
    }
  }

  viewer_certificate = {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  web_acl_id = aws_wafv2_web_acl.app_waf.arn
}


resource "aws_wafv2_web_acl" "app_waf" {
  provider    = aws.useast1

  name        = "app-waf"
  scope       = "CLOUDFRONT"
  description = "WAF for protecting app"

  default_action {
    allow {}
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "awsCommonRules"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "webACL"
    sampled_requests_enabled   = true
  }
}
