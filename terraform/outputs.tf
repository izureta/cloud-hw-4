output "app_public_ip" {
  description = "Публичный IP VM-1 (приложение) — для ssh и scp"
  value       = yandex_compute_instance.app.network_interface[0].nat_ip_address
}

output "app_internal_ip" {
  description = "Внутренний IP VM-1 — подставить в конфиги load testing вместо YOUR_APP_IP"
  value       = yandex_compute_instance.app.network_interface[0].ip_address
}

output "monitoring_public_ip" {
  description = "Публичный IP VM-2 (мониторинг) — Grafana :3000, Prometheus :9090"
  value       = yandex_compute_instance.monitoring.network_interface[0].nat_ip_address
}

output "bucket_website_url" {
  description = "URL бакета как веб-сайта — вставить в форму сдачи ДЗ"
  value       = "https://${yandex_storage_bucket.reports.bucket}.website.yandexcloud.net"
}

output "scp_command" {
  description = "Команда для копирования приложения на VM-1"
  value       = "scp -r ../flask-style-transfer ubuntu@${yandex_compute_instance.app.network_interface[0].nat_ip_address}:~"
}
