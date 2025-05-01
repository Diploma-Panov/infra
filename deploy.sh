#!/bin/bash
set -e

echo "Planning Infrastructure Deployment"
terraform -chdir=aws plan \
  -var="sendgrid_api_key=${SENDGRID_API_KEY}" \
  -var="deployer_arn=${DEPLOYER_ARN}" \
  -var="acm_certificate_arn=${ACM_CERTIFICATE_ARN}" \
  -var="route53_zone_id=${ROUTE_53_ZONE_ID}" \
  -var="system_token=${SYSTEM_TOKEN}" \
  -var="auth_service_secret_arn=${SECRET_ARN}" \
  -out=tfplan-infra

echo "🔄 Updating kubeconfig..."
aws eks update-kubeconfig \
  --region eu-central-1 \
  --name diploma-cluster \
  --kubeconfig ./kubeconfig

export KUBECONFIG=./kubeconfig

echo "Applying Infrastructure"
terraform -chdir=aws apply tfplan-infra

echo "✅ Deployment successful!"
