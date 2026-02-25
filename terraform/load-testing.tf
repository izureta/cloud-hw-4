resource "yandex_loadtesting_agent" "hw4" {
  name = "hw4-agent"

  compute_instance {
    zone_id            = var.zone
    service_account_id = yandex_iam_service_account.load_testing.id

    resources {
      memory        = 2
      cores         = 2
      core_fraction = 100
    }

    boot_disk {
      initialize_params {
        size = 15
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
            groups: sudo
            sudo: ALL=(ALL) NOPASSWD:ALL
            shell: /bin/bash
            ssh_authorized_keys:
              - ${local.ssh_key}
      EOT
    }
  }
}
