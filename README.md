# Infrastructure
Terraform AWS infrastructure of diploma project

## Onboarding
1. Prepare environment variables
```shell
export SENDGRID_API_KEY=...    # API key for Auth Service's email sending
export DEPLOYER_ARN=...        # AWS ARN identifier of admin deployer user
export ACM_CERTIFICATE_ARN=... # Single ACM certificate for mpanov.com, cdn.urls.mpanov.com and api.urls.mpanov.com
export ROUTE_53_ZONE_ID=...    # AWS ARN identifier of the mpanov.com hosted zone in Route 53
export SYSTEM_TOKEN=...        # Authorization token for cross-microservice communication
export SECRET_ARN=...          # AWS ARN identifier of Secrets Manager's secret for auth-service application
```

2. Install `kubectl`
https://kubernetes.io/docs/tasks/tools/

3. Make changes in Terraform configurations

4. Apply changes of the infrastructure (or launch from scratch if it is currently inactive)
```shell
./deploy.sh
```

5. Make changes in Kubernetes configuration

6. Apply changes to Kubernetes cluster and services
```shell
kubectl apply -f ./k8s/rendered-ingress.yaml -f ./k8s/auth-service -f ./k8s/shortener-service
```
Or if you want to update specific configuration
```shell
kubectl apply -f ./k8s/auth-service
kubectl apply -f ./k8s/shortener-service/deployment.yaml
```

7. (Optional) Reload all services (update images)
```shell
kubectl rollout restart deployment
```

8. Destroy the infrastructure completely
```shell
kubectl destroy -f ./k8s/rendered-ingress.yaml ./k8s/auth-service ./k8s/shortener-service
./destroy.sh
```