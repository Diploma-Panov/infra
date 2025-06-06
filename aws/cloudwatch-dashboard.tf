resource "aws_cloudwatch_dashboard" "infra_and_apps" {
  dashboard_name = "infra-and-apps-overview"

  dashboard_body = jsonencode({
    widgets = [

      {
        type   = "metric"
        x      = 0
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
          stat        = "Average"
          period      = 60
          annotations = { horizontal = [], vertical = [] }
        }
      },

      {
        type   = "metric"
        x      = 6
        y      = 6
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
          stat        = "Average"
          period      = 60
          annotations = { horizontal = [], vertical = [] }
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 6
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
          stat        = "Average"
          period      = 60
          annotations = { horizontal = [], vertical = [] }
        }
      },

      {
        type   = "metric"
        x      = 18
        y      = 6
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "eu-central-1"
          title   = "DynamoDB Read Capacity"
          stacked = false
          metrics = [
            [
              "AWS/DynamoDB", "ConsumedReadCapacityUnits",
              "TableName", aws_dynamodb_table.shortener_links.name
            ]
          ]
          stat        = "Sum"
          period      = 60
          annotations = { horizontal = [], vertical = [] }
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 24
        width  = 6
        height = 6
        properties = {
          view   = "timeSeries"
          region = "eu-central-1"
          title  = "API Server Request Rate"
          metrics = [
            [
              {
                id         = "e1"
                expression = "SEARCH('Namespace=\\\"AWS/EKS\\\" AND ClusterName=\\\"${module.eks.cluster_name}\\\" AND MetricName=\\\"apiserver_request_total\\\"', 'Average', 60)"
                label      = "Request Rate"
                period     = 60
              }
            ]
          ]
          annotations = { horizontal = [], vertical = [] }
        }
      },

      {
        type   = "metric"
        x      = 6
        y      = 24
        width  = 6
        height = 6
        properties = {
          view   = "timeSeries"
          region = "eu-central-1"
          title  = "ALB 4XX Errors (Count)"
          metrics = [
            [
              {
                id         = "e2"
                expression = "SEARCH('Namespace=\\\"AWS/ApplicationELB\\\" AND LoadBalancer=\\\"${data.aws_lb.diploma_ingress_alb.name}\\\" AND MetricName=\\\"HTTPCode_ELB_4XX_Count\\\"', 'Sum', 60)"
                label      = "4XX Errors"
                period     = 60
              }
            ]
          ]
          annotations = { horizontal = [], vertical = [] }
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 24
        width  = 6
        height = 6
        properties = {
          view   = "timeSeries"
          region = "eu-central-1"
          title  = "ALB 5XX Errors (Count)"
          metrics = [
            [
              {
                id         = "e3"
                expression = "SEARCH('Namespace=\\\"AWS/ApplicationELB\\\" AND LoadBalancer=\\\"${data.aws_lb.diploma_ingress_alb.name}\\\" AND MetricName=\\\"HTTPCode_ELB_5XX_Count\\\"', 'Sum', 60)"
                label      = "5XX Errors"
                period     = 60
              }
            ]
          ]
          annotations = { horizontal = [], vertical = [] }
        }
      },

      {
        type   = "metric"
        x      = 18
        y      = 24
        width  = 6
        height = 6
        properties = {
          view   = "timeSeries"
          region = "eu-central-1"
          title  = "ALB Request Count"
          metrics = [
            [
              {
                id         = "e4"
                expression = "SEARCH('Namespace=\\\"AWS/ApplicationELB\\\" AND LoadBalancer=\\\"${data.aws_lb.diploma_ingress_alb.name}\\\" AND MetricName=\\\"RequestCount\\\"', 'Sum', 60)"
                label      = "Request Count"
                period     = 60
              }
            ]
          ]
          annotations = { horizontal = [], vertical = [] }
        }
      },

    ]
  })
}
