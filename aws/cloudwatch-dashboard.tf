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
          view        = "timeSeries"
          region      = "eu-central-1"
          title       = "EKS Healthy Hosts"
          stacked     = false
          metrics     = [
            [ "AWS/EKS", "HealthyHostCount", "ClusterName", module.eks.cluster_name ]
          ]
          stat        = "Average"
          period      = 300
          annotations = {
            horizontal = []
            vertical   = []
          }
        }
      },

      {
        type   = "metric"
        x      = 6
        y      = 0
        width  = 6
        height = 6
        properties = {
          view        = "timeSeries"
          region      = "eu-central-1"
          title       = "Node CPU Utilization"
          stacked     = false
          metrics     = [
            [
              "AWS/EC2", "CPUUtilization",
              "Tag:kubernetes.io/cluster/${module.eks.cluster_name}", "shared"
            ]
          ]
          stat        = "Average"
          period      = 300
          annotations = {
            horizontal = []
            vertical   = []
          }
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 6
        height = 6
        properties = {
          view        = "timeSeries"
          region      = "eu-central-1"
          title       = "Node Memory Utilization"
          stacked     = false
          metrics     = [
            [
              "CWAgent", "mem_used_percent",
              "ClusterName", module.eks.cluster_name
            ]
          ]
          stat        = "Average"
          period      = 300
          annotations = {
            horizontal = []
            vertical   = []
          }
        }
      },

      {
        type   = "metric"
        x      = 6
        y      = 6
        width  = 6
        height = 6
        properties = {
          view        = "timeSeries"
          region      = "eu-central-1"
          title       = "RDS Freeable Memory"
          stacked     = false
          metrics     = [
            [
              "AWS/RDS", "FreeableMemory",
              "DBInstanceIdentifier", aws_db_instance.auth_db.identifier
            ],
            [
              ".", "FreeableMemory",
              ".", aws_db_instance.shortener_db.identifier
            ]
          ]
          stat        = "Average"
          period      = 300
          annotations = {
            horizontal = []
            vertical   = []
          }
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 6
        height = 6
        properties = {
          view        = "timeSeries"
          region      = "eu-central-1"
          title       = "RDS DB Connections"
          stacked     = false
          metrics     = [
            [
              "AWS/RDS", "DatabaseConnections",
              "DBInstanceIdentifier", aws_db_instance.auth_db.identifier
            ],
            [
              ".", "DatabaseConnections",
              ".", aws_db_instance.shortener_db.identifier
            ]
          ]
          stat        = "Average"
          period      = 300
          annotations = {
            horizontal = []
            vertical   = []
          }
        }
      },

      {
        type   = "metric"
        x      = 6
        y      = 12
        width  = 6
        height = 6
        properties = {
          view        = "timeSeries"
          region      = "eu-central-1"
          title       = "Redis Current Connections"
          stacked     = false
          metrics     = [
            [
              "AWS/ElastiCache", "CurrConnections",
              "CacheClusterId", aws_elasticache_cluster.redis.cluster_id
            ]
          ]
          stat        = "Average"
          period      = 300
          annotations = {
            horizontal = []
            vertical   = []
          }
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 6
        height = 6
        properties = {
          view        = "timeSeries"
          region      = "eu-central-1"
          title       = "ALB Target Latency (ms)"
          stacked     = false
          metrics     = [
            [
              "AWS/ApplicationELB", "TargetResponseTime",
              "LoadBalancer", data.aws_lb.diploma_ingress_alb.name
            ]
          ]
          stat        = "Average"
          period      = 60
          annotations = {
            horizontal = []
            vertical   = []
          }
        }
      },
    ]
  })
}
