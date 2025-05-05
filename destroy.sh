#!/bin/bash
set -e

aws eks update-kubeconfig \
  --region eu-central-1 \
  --name diploma-cluster

kubectl delete -f=./k8s --recursive

kubectl delete ingress diploma-ingress \
  -n default \
  --grace-period=0 \
  --force \
  --wait=false

kubectl patch ingress diploma-ingress \
  -n default \
  --type=merge \
  -p '{"metadata":{"finalizers":[]}}'

terraform -chdir=aws destroy \
  -var="alb_certificate_arn=${ALB_CERTIFICATE_ARN}" \
  -var="sendgrid_api_key=${SENDGRID_API_KEY}" \
  -var="deployer_arn=${DEPLOYER_ARN}" \
  -var="github_actions_deployer_arn=${ACTIONS_DEPLOYER_ARN}" \
  -var="acm_certificate_arn=${ACM_CERTIFICATE_ARN}" \
  -var="route53_zone_id=${ROUTE_53_ZONE_ID}" \
  -var="system_token=${SYSTEM_TOKEN}" \
  -auto-approve
