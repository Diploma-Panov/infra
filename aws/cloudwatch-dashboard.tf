# ──────────────────────────────────────────────────
data "aws_lb_target_group" "auth_tg" {
  tags = {
    "ingress.k8s.aws/resource": "default/diploma-ingress-auth-service:80"
  }
}

data "aws_lb_target_group" "shortener_tg" {
  tags = {
    "ingress.k8s.aws/resource": "default/diploma-ingress-shortener-service:80"
  }
}


# ──────────────────────────────────────────────────
resource "aws_cloudwatch_dashboard" "infra_and_apps" {
  dashboard_name = "infra-and-apps-overview"

  dashboard_body = jsonencode({
    widgets = [

      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "eu-central-1"
          title   = "Auth TG Healthy Hosts"
          stacked = false
          metrics = [
            [
              "AWS/ApplicationELB", "HealthyHostCount",
              "TargetGroup", data.aws_lb_target_group.auth_tg.arn_suffix
            ]
          ]
          stat   = "Average"
          period = 300
        }
      },

      # 2) Node CPU Utilization (by EKS tag “owned”)
      {
        type   = "metric"
        x      = 6
        y      = 0
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "eu-central-1"
          title   = "Node CPU Utilization"
          stacked = false
          metrics = [
            [
              "AWS/EC2", "CPUUtilization",
              "Tag:kubernetes.io/cluster/${module.eks.cluster_name}", "owned"
            ]
          ]
          stat   = "Average"
          period = 300
        }
      },

      # 3) Node Memory Utilization (roll up across all nodes)
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "eu-central-1"
          title   = "Node Memory Utilization"
          stacked = false
          metrics = [
            [
              "CWAgent", "mem_used_percent",
              "InstanceId", "*"
            ]
          ]
          stat   = "Average"
          period = 300
        }
      },

      # 4) RDS Freeable Memory (two DB instances)
      {
        type   = "metric"
        x      = 6
        y      = 6
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "eu-central-1"
          title   = "RDS Freeable Memory"
          stacked = false
          metrics = [
            [
              "AWS/RDS", "FreeableMemory",
              "DBInstanceIdentifier", aws_db_instance.auth_db.identifier
            ],
            [
              ".", "FreeableMemory",
              ".", aws_db_instance.shortener_db.identifier
            ]
          ]
          stat   = "Average"
          period = 300
        }
      },

      # 5) RDS DB Connections (two DB instances)
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "eu-central-1"
          title   = "RDS DB Connections"
          stacked = false
          metrics = [
            [
              "AWS/RDS", "DatabaseConnections",
              "DBInstanceIdentifier", aws_db_instance.auth_db.identifier
            ],
            [
              ".", "DatabaseConnections",
              ".", aws_db_instance.shortener_db.identifier
            ]
          ]
          stat   = "Average"
          period = 300
        }
      },

      # 6) Redis Current Connections
      {
        type   = "metric"
        x      = 6
        y      = 12
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "eu-central-1"
          title   = "Redis Current Connections"
          stacked = false
          metrics = [
            [
              "AWS/ElastiCache", "CurrConnections",
              "CacheClusterId", aws_elasticache_cluster.redis.cluster_id
            ]
          ]
          stat   = "Average"
          period = 300
        }
      },

      # 7) ALB Target Latency (TargetResponseTime requires LoadBalancer + TargetGroup)
      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "eu-central-1"
          title   = "ALB Target Latency (ms)"
          stacked = false
          metrics = [
            [
              "AWS/ApplicationELB", "TargetResponseTime",
              "LoadBalancer", data.aws_lb.diploma_ingress_alb.name,
              "TargetGroup", data.aws_lb_target_group.auth_tg.arn_suffix
            ]
          ]
          stat   = "Average"
          period = 60
        }
      },

      # 8) (Optional) Shortener TG Healthy Hosts
      {
        type   = "metric"
        x      = 6
        y      = 18
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "eu-central-1"
          title   = "Shortener TG Healthy Hosts"
          stacked = false
          metrics = [
            [
              "AWS/ApplicationELB", "HealthyHostCount",
              "TargetGroup", data.aws_lb_target_group.shortener_tg.arn_suffix
            ]
          ]
          stat   = "Average"
          period = 300
        }
      },

    ]
  })
}
