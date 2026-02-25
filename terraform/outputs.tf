output "app_public_ip" {
  description = "VM-1 public IP"
  value       = yandex_compute_instance.app.network_interface[0].nat_ip_address
}

output "app_internal_ip" {
  description = "VM-1 internal IP"
  value       = yandex_compute_instance.app.network_interface[0].ip_address
}

output "monitoring_public_ip" {
  description = "VM-2 public IP (Grafana :3000, Prometheus :9090)"
  value       = yandex_compute_instance.monitoring.network_interface[0].nat_ip_address
}

output "bucket_website_url" {
  description = "Object Storage bucket website URL"
  value       = "https://${yandex_storage_bucket.reports.bucket}.website.yandexcloud.net"
}

output "scp_command" {
  description = "Copy app to VM-1"
  value       = "scp -r ../flask-style-transfer ubuntu@${yandex_compute_instance.app.network_interface[0].nat_ip_address}:~"
}
