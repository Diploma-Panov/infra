apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: diploma-ingress
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}]'
    alb.ingress.kubernetes.io/certificate-arn: "${ALB_CERTIFICATE_ARN}"
    alb.ingress.kubernetes.io/ssl-policy: "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
spec:
  ingressClassName: alb
  rules:
    - host: api.urls.mpanov.com
      http:
        paths:
          - path: /api/auth/
            pathType: Prefix
            backend:
              service:
                name: auth-service
                port:
                    number: 80
          - path: /api/shrt/
            pathType: Prefix
            backend:
              service:
                name: shortener-service
                port:
                    number: 80
    - host: mpanov.com
      http:
        paths:
          - path: /r/
            pathType: Prefix
            backend:
              service:
                name: shortener-service
                port:
                    number: 80
