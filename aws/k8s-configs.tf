resource "kubernetes_config_map" "auth_service_configs" {
  metadata {
    name      = "auth-service-configs"
    namespace = "default"
  }

  data = {
    "server.port"                              = "80"
    "sendgrid.api-key"                         = var.sendgrid_api_key
    "platform.errors.hide-message"             = "true"
    "platform.is-test"                         = "false"
    "platform.env"                             = "prod"
    "spring.datasource.url"                    = "jdbc:postgresql://${aws_db_instance.auth_db.address}:${aws_db_instance.auth_db.port}/${aws_db_instance.auth_db.db_name}"
    "spring.datasource.username"               = "authdbuser"
    "spring.datasource.password"               = random_password.rds_auth.result
    "spring.datasource.hikari.maximumPoolSize" = "80"
    "spring.data.redis.host"                   = aws_elasticache_cluster.redis.cache_nodes[0].address
    "spring.data.redis.port"                   = "6379"
    "spring.kafka.bootstrap-servers"           = aws_msk_cluster.kafka_cluster.bootstrap_brokers
    "shortener.base-url"                       = "https://urls.mpanov.com"
    "s3.image-bucket"                          = aws_s3_bucket.auth_service_images.bucket
    "platform.system-token"                    = var.system_token
    "cdn.base-url"                             = "https://cdn.urls.mpanov.com/"
  }

  depends_on = [
    aws_msk_cluster.kafka_cluster
  ]
}


resource "kubernetes_config_map" "shortener_service_configs" {
  metadata {
    name      = "shortener-service-configs"
    namespace = "default"
  }

  data = {
    DRIZZLE_SSL             = "false"
    LOG_LEVEL               = "TRACE"
    SERVER_PORT             = "80"
    DB_HOST                 = aws_db_instance.shortener_db.address
    DB_PORT                 = "5432"
    DB_PRIMARY_DATABASE     = "shortener_service_database"
    DB_USERNAME             = "shortenerdbuser"
    DB_PASSWORD             = random_password.rds_shortener.result
    KAFKA_BOOTSTRAP_SERVER  = aws_msk_cluster.kafka_cluster.bootstrap_brokers
    AUTH_SERVICE_BASE_URL   = "http://auth-service"
    SHORT_URL_BASE          = "https://mpanov.com/r"
    SYSTEM_TOKEN            = var.system_token
    REDIS_URL               = "redis://${aws_elasticache_cluster.redis.cache_nodes[0].address}:6379"
    STATS_TABLE_NAME        = aws_dynamodb_table.shortener_links.name
  }

  depends_on = [
    aws_msk_cluster.kafka_cluster
  ]
}
