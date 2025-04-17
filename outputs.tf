output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.ecs_cluster.ecs_cluster_name
}

output "app_service_name" {
  description = "ECS service name for Node.js and MongoDB app"
  value       = module.ecs_cluster.app_service_name
}

output "prometheus_grafana_service_name" {
  description = "ECS service name for Prometheus and Grafana"
  value       = module.ecs_cluster.prometheus_grafana_service_name
}

output "monitoring_alb_dns" {
  description = "DNS name to access Prometheus and Grafana"
  value       = module.ecs_cluster.monitoring_alb_dns
}
