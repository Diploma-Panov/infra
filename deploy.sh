#!/bin/bash
set -e

echo $ACTIONS_DEPLOYER_ARN

echo "Planning & Applying *all* Infrastructure"
terraform -chdir=aws plan \
  -var="alb_certificate_arn=${ALB_CERTIFICATE_ARN}" \
  -var="sendgrid_api_key=${SENDGRID_API_KEY}" \
  -var="deployer_arn=${DEPLOYER_ARN}" \
  -var="github_actions_deployer_arn=${ACTIONS_DEPLOYER_ARN}" \
  -var="acm_certificate_arn=${ACM_CERTIFICATE_ARN}" \
  -var="route53_zone_id=${ROUTE_53_ZONE_ID}" \
  -var="system_token=${SYSTEM_TOKEN}" \
  -out=tfplan-infra

terraform -chdir=aws apply tfplan-infra

echo "✅ Deployment successful!"
