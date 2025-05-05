variable "acm_certificate_arn" {
  description = "ACM Certificate ARN for Cloudfront"
  type        = string
}

variable "alb_certificate_arn" {
  description = "ALB Certificate ARN for HTTPS listener"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "system_token" {
  description = "System authentication token used by services"
  type        = string
  sensitive   = true
}

variable "deployer_arn" {
  description = "Kubernetes deployer user/role ARN"
  type        = string
}

variable "sendgrid_api_key" {
  description = "SendGrid API key"
  type        = string
}