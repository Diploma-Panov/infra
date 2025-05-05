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

2. Install `kubectl` and `terraform`
https://kubernetes.io/docs/tasks/tools/
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

3. Initialize Terraform
```shell
cd aws
terraform init
terraform get
cd ..
```

4. Make changes in Terraform configurations

5. Apply changes of the infrastructure (or launch from scratch if it is currently inactive)
```shell
./deploy.sh
```

6. Make changes in Kubernetes configuration
```
Note that you should only change ingress.yaml.template since
rendered-ingress.yaml is a temporal working file.
```

7. Apply changes to Kubernetes cluster and services
```shell
./deploy.sh # If you added changes in ./k8s/ingress.yaml.template
kubectl apply -f ./k8s --recursive
```
Or if you want to update specific configuration
```shell
kubectl apply -f ./k8s/auth-service
kubectl apply -f ./k8s/shortener-service/deployment.yaml
```

8. (Optional) Reload all services (update images)
```shell
kubectl rollout restart deployment
```

9. Destroy the infrastructure completely
```shell
kubectl destroy -f ./k8s/rendered-ingress.yaml ./k8s/auth-service ./k8s/shortener-service
./destroy.sh
```