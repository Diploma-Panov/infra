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

      {
        type   = "metric"
        x      = 6
        y      = 0
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

      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "eu-central-1"
          title   = "Node Network In"
          stacked = false
          metrics = [
            [
              "AWS/EC2", "NetworkIn",
              "Tag:kubernetes.io/cluster/${module.eks.cluster_name}", "owned"
            ]
          ]
          stat   = "Sum"
          period = 300
        }
      },

      {
        type   = "metric"
        x      = 18
        y      = 0
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "eu-central-1"
          title   = "Node Network Out"
          stacked = false
          metrics = [
            [
              "AWS/EC2", "NetworkOut",
              "Tag:kubernetes.io/cluster/${module.eks.cluster_name}", "owned"
            ]
          ]
          stat   = "Sum"
          period = 300
        }
      },

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
          stat   = "Average"
          period = 300
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
          stat   = "Average"
          period = 300
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
          stat   = "Average"
          period = 300
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
          stat   = "Sum"
          period = 300
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "eu-central-1"
          title   = "ALB Request Count"
          stacked = false
          metrics = [
            [
              "AWS/ApplicationELB", "RequestCount",
              "LoadBalancer", data.aws_lb.diploma_ingress_alb.name
            ]
          ]
          stat   = "Sum"
          period = 60
        }
      },

      {
        type   = "metric"
        x      = 6
        y      = 12
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "eu-central-1"
          title   = "ALB Healthy Hosts"
          stacked = false
          metrics = [
            [
              "AWS/ApplicationELB", "HealthyHostCount",
              "LoadBalancer", data.aws_lb.diploma_ingress_alb.name
            ]
          ]
          stat   = "Average"
          period = 60
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "eu-central-1"
          title   = "ALB 5XX Errors"
          stacked = false
          metrics = [
            [
              "AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count",
              "LoadBalancer", data.aws_lb.diploma_ingress_alb.name
            ]
          ]
          stat   = "Sum"
          period = 60
        }
      },

      {
        type   = "metric"
        x      = 18
        y      = 12
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "eu-central-1"
          title   = "ALB 4XX Errors"
          stacked = false
          metrics = [
            [
              "AWS/ApplicationELB", "HTTPCode_ELB_4XX_Count",
              "LoadBalancer", data.aws_lb.diploma_ingress_alb.name
            ]
          ]
          stat   = "Sum"
          period = 60
        }
      },


      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "eu-central-1"
          title   = "DynamoDB Write Capacity"
          stacked = false
          metrics = [
            [
              "AWS/DynamoDB", "ConsumedWriteCapacityUnits",
              "TableName", aws_dynamodb_table.shortener_links.name
            ]
          ]
          stat   = "Sum"
          period = 300
        }
      },

      {
        type   = "metric"
        x      = 6
        y      = 18
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "eu-central-1"
          title   = "DynamoDB Throttle Events"
          stacked = false
          metrics = [
            [
              "AWS/DynamoDB", "WriteThrottleEvents",
              "TableName", aws_dynamodb_table.shortener_links.name
            ]
          ]
          stat   = "Sum"
          period = 300
        }
      },

      {
        type   = "metric"
        x      = 12
        y      = 18
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "eu-central-1"
          title   = "S3 Bucket Size (Bytes)"
          stacked = false
          metrics = [
            [
              "AWS/S3", "BucketSizeBytes",
              "BucketName", aws_s3_bucket.auth_service_images.bucket,
              "StorageType", "StandardStorage"
            ]
          ]
          stat   = "Average"
          period = 86400
        }
      },

      {
        type   = "metric"
        x      = 18
        y      = 18
        width  = 6
        height = 6
        properties = {
          view    = "timeSeries"
          region  = "eu-central-1"
          title   = "S3 Number of Objects"
          stacked = false
          metrics = [
            [
              "AWS/S3", "NumberOfObjects",
              "BucketName", aws_s3_bucket.auth_service_images.bucket,
              "StorageType", "AllStorageTypes"
            ]
          ]
          stat   = "Average"
          period = 86400
        }
      },

    ]
  })
}
