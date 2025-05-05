resource "aws_cloudwatch_dashboard" "infra_and_apps" {
  dashboard_name = "infra-and-apps-overview"
  dashboard_body = jsonencode({
    widgets = [

      # ========== ROW 1: Cluster Health & Utilization ==========
      {
        type       = "metric"
        x          = 0
        y          = 0
        width      = 6
        height     = 6
        properties = {
          title   = "EKS Healthy Node Count"
          metrics = [
            [ "AWS/EKS", "HealthyNodeCount", "ClusterName", module.eks.cluster_name ]
          ]
          stat   = "Average"
          period = 300
        }
      },
      {
        type       = "metric"
        x          = 6
        y          = 0
        width      = 6
        height     = 6
        properties = {
          title   = "Node CPU Utilization (all EC2)"
          metrics = [
            [ "AWS/EC2", "CPUUtilization" ]
          ]
          stat   = "Average"
          period = 300
        }
      },
      {
        type       = "metric"
        x          = 12
        y          = 0
        width      = 6
        height     = 6
        properties = {
          title   = "Node Memory Used %"
          metrics = [
            [ "CWAgent", "mem_used_percent", "clusterName", module.eks.cluster_name ]
          ]
          stat   = "Average"
          period = 300
        }
      },

      # ========== ROW 2: RDS ==========
      {
        type       = "metric"
        x          = 0
        y          = 6
        width      = 6
        height     = 6
        properties = {
          title   = "Auth-DB FreeableMemory"
          metrics = [
            [ "AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", aws_db_instance.auth_db.id ]
          ]
          stat   = "Average"
          period = 300
        }
      },
      {
        type       = "metric"
        x          = 6
        y          = 6
        width      = 6
        height     = 6
        properties = {
          title   = "Auth-DB DBConnections"
          metrics = [
            [ "AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", aws_db_instance.auth_db.id ]
          ]
          stat   = "Average"
          period = 300
        }
      },
      {
        type       = "metric"
        x          = 12
        y          = 6
        width      = 6
        height     = 6
        properties = {
          title   = "Shortener-DB FreeableMemory"
          metrics = [
            [ "AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", aws_db_instance.shortener_db.id ]
          ]
          stat   = "Average"
          period = 300
        }
      },
      {
        type       = "metric"
        x          = 18
        y          = 6
        width      = 6
        height     = 6
        properties = {
          title   = "Shortener-DB DBConnections"
          metrics = [
            [ "AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", aws_db_instance.shortener_db.id ]
          ]
          stat   = "Average"
          period = 300
        }
      },

      # ========== ROW 3: Redis ==========
      {
        type       = "metric"
        x          = 0
        y          = 12
        width      = 6
        height     = 6
        properties = {
          title   = "Redis Cache Bytes Used"
          metrics = [
            [ "AWS/ElastiCache", "BytesUsedForCache", "CacheClusterId", aws_elasticache_cluster.redis.id ]
          ]
          stat   = "Average"
          period = 300
        }
      },
      {
        type       = "metric"
        x          = 6
        y          = 12
        width      = 6
        height     = 6
        properties = {
          title   = "Redis Current Connections"
          metrics = [
            [ "AWS/ElastiCache", "CurrConnections", "CacheClusterId", aws_elasticache_cluster.redis.id ]
          ]
          stat   = "Average"
          period = 300
        }
      },

      # ========== ROW 4: ALB ==========
      {
        type       = "metric"
        x          = 0
        y          = 18
        width      = 12
        height     = 6
        properties = {
          title   = "ALB Target Response Time"
          metrics = [
            [ "AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", data.aws_lb.diploma_ingress_alb.name ]
          ]
          stat   = "Average"
          period = 300
        }
      },

      # ========== ROW 5: Per-Service Container Insights ==========
      {
        type       = "metric"
        x          = 0
        y          = 24
        width      = 6
        height     = 6
        properties = {
          title   = "Auth-Service CPU %"
          metrics = [
            [ "ContainerInsights", "cpu_utilization", "ClusterName", module.eks.cluster_name, "ContainerName", "auth-service" ]
          ]
          stat   = "Average"
          period = 300
        }
      },
      {
        type       = "metric"
        x          = 6
        y          = 24
        width      = 6
        height     = 6
        properties = {
          title   = "Auth-Service Mem %"
          metrics = [
            [ "ContainerInsights", "memory_utilization", "ClusterName", module.eks.cluster_name, "ContainerName", "auth-service" ]
          ]
          stat   = "Average"
          period = 300
        }
      },
      {
        type       = "metric"
        x          = 12
        y          = 24
        width      = 6
        height     = 6
        properties = {
          title   = "Shortener-Svc CPU %"
          metrics = [
            [ "ContainerInsights", "cpu_utilization", "ClusterName", module.eks.cluster_name, "ContainerName", "shortener-service" ]
          ]
          stat   = "Average"
          period = 300
        }
      },
      {
        type       = "metric"
        x          = 18
        y          = 24
        width      = 6
        height     = 6
        properties = {
          title   = "Shortener-Svc Mem %"
          metrics = [
            [ "ContainerInsights", "memory_utilization", "ClusterName", module.eks.cluster_name, "ContainerName", "shortener-service" ]
          ]
          stat   = "Average"
          period = 300
        }
      },

    ]
  })
}
