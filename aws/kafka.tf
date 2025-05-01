resource "aws_msk_cluster" "kafka_cluster" {
  cluster_name           = "kafka-cluster"
  kafka_version          = "2.8.1"
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type   = "kafka.t3.small"
    client_subnets  = module.vpc.private_subnets
    security_groups = [
      module.vpc.default_security_group_id,
      aws_security_group.managed_services_sg.id
    ]
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "PLAINTEXT"
      in_cluster    = false
    }
  }
}
