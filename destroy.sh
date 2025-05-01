#!/bin/bash
set -e

terraform -chdir=aws destroy \
  -var="sendgrid_api_key=${SENDGRID_API_KEY}" \
  -var="deployer_arn=${DEPLOYER_ARN}" \
  -var="acm_certificate_arn=${ACM_CERTIFICATE_ARN}" \
  -var="route53_zone_id=${ROUTE_53_ZONE_ID}" \
  -var="system_token=${SYSTEM_TOKEN}" \
  -var="auth_service_secret_arn=${SECRET_ARN}" \
  -auto-approve
