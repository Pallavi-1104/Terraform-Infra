output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "app_service_name" {
  value = aws_ecs_service.app_service.name
}

output "prometheus_grafana_service_name" {
  value = aws_ecs_service.prometheus_grafana.name
}

output "monitoring_alb_dns" {
  description = "DNS name of the monitoring ALB"
  value       = aws_lb.monitoring_alb.dns_name
}
