data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

locals {
  ssh_key = file(pathexpand(var.ssh_public_key_path))
}

# VM-1: приложение + node exporter
# 4GB нужны OpenCV DNN — инференс style transfer держит в памяти модель + буферы изображений
# 100% fraction — CPU-bound задача, shared CPU замедлит инференс кратно
resource "yandex_compute_instance" "app" {
  name        = "hw4-app"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 15  # Ubuntu + Docker + venv + модели (~500MB) укладываются в 15GB
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.hw4.id
    nat       = true  # публичный IP для деплоя через scp/ssh
  }

  metadata = {
    user-data = <<-EOT
      #cloud-config
      users:
        - name: ubuntu
          groups: sudo, docker
          sudo: ALL=(ALL) NOPASSWD:ALL
          shell: /bin/bash
          ssh_authorized_keys:
            - ${local.ssh_key}

      apt:
        sources:
          docker.list:
            source: deb [arch=amd64] https://download.docker.com/linux/ubuntu $RELEASE stable
            keyid: 9DC858229FC7DD38854AE2D88D81803C0EBFCD88

      packages:
        - docker-ce
        - docker-ce-cli
        - python3-pip
        - python3-venv

      runcmd:
        # node exporter на порту 9100
        - docker run -d --restart=always --name=node-exporter
          --net=host --pid=host
          -v /:/host:ro,rslave
          prom/node-exporter:latest
          --path.rootfs=/host
    EOT
  }
}

# VM-2: Prometheus + Grafana
# Prometheus ~200MB + Grafana ~300MB + OS = ~1GB, 2GB с запасом
# 20% fraction достаточно — мониторинг не CPU-bound
resource "yandex_compute_instance" "monitoring" {
  name        = "hw4-monitoring"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 15  # Docker images prometheus+grafana ~1GB, данные за пару часов теста < 1GB
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.hw4.id
    nat       = true
  }

  metadata = {
    user-data = <<-EOT
      #cloud-config
      users:
        - name: ubuntu
          groups: sudo, docker
          sudo: ALL=(ALL) NOPASSWD:ALL
          shell: /bin/bash
          ssh_authorized_keys:
            - ${local.ssh_key}

      apt:
        sources:
          docker.list:
            source: deb [arch=amd64] https://download.docker.com/linux/ubuntu $RELEASE stable
            keyid: 9DC858229FC7DD38854AE2D88D81803C0EBFCD88

      packages:
        - docker-ce
        - docker-ce-cli
        - docker-compose-plugin

      write_files:
        - path: /opt/monitoring/prometheus.yml
          content: |
            global:
              scrape_interval: 5s

            scrape_configs:
              - job_name: 'node'
                static_configs:
                  - targets: ['${yandex_compute_instance.app.network_interface[0].ip_address}:9100']

              - job_name: 'app'
                static_configs:
                  - targets: ['${yandex_compute_instance.app.network_interface[0].ip_address}:8000']
                metrics_path: '/metrics'

        - path: /opt/monitoring/docker-compose.yml
          content: |
            version: '3.8'
            services:
              prometheus:
                image: prom/prometheus:latest
                container_name: prometheus
                volumes:
                  - ./prometheus.yml:/etc/prometheus/prometheus.yml
                  - prometheus_data:/prometheus
                command:
                  - '--config.file=/etc/prometheus/prometheus.yml'
                  - '--web.enable-lifecycle'
                ports:
                  - "9090:9090"
                restart: unless-stopped
              grafana:
                image: grafana/grafana:latest
                container_name: grafana
                volumes:
                  - grafana_data:/var/lib/grafana
                ports:
                  - "3000:3000"
                restart: unless-stopped
            volumes:
              prometheus_data:
              grafana_data:

      runcmd:
        - cd /opt/monitoring && docker compose up -d
    EOT
  }
}
