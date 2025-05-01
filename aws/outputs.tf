output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

# output "alb_dns" {
#   value = module.alb.lb_dns_name
# }
#
# output "alb_zone_id" {
#   value = module.alb.lb_zone_id
# }

output "kafka_bootstrap_servers" {
  description = "Comma-separated MSK bootstrap brokers"
  value       = aws_msk_cluster.kafka_cluster.bootstrap_brokers
}