terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.100"
    }
  }
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

resource "yandex_vpc_network" "hw4" {
  name = "hw4-network"
}

resource "yandex_vpc_subnet" "hw4" {
  name           = "hw4-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.hw4.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
