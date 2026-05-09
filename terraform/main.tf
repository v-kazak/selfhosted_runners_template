terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token    = var.token
  cloud_id = var.cloud_id
  zone     = var.zone
}

resource "yandex_compute_instance" "instance" {
  name        = "${var.name}-${count.index}"
  platform_id = var.platform_type
  zone        = var.zone
  folder_id   = var.folder_id
  count       = var.vps_count


  resources {
    cores         = var.cores_count
    memory        = var.memory_count
    core_fraction = var.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      type     = var.disc_type
      size     = var.disc_size
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.net.id
    nat                = var.nat
    security_group_ids = [yandex_vpc_security_group.sg1.id]
  }

  metadata = {
    user-data = <<-EOF
      #cloud-config
      users:
        - name: ${var.ssh_user}
          groups: sudo
          shell: /bin/bash
          sudo: ['ALL=(ALL) NOPASSWD:ALL']
          ssh_authorized_keys:
            - ${trimspace(file(var.ssh_public_key_path))}
    EOF
  }

  scheduling_policy {
    preemptible = var.preemptible
  }

}

resource "yandex_vpc_network" "net" {
  name      = "net"
  folder_id = var.folder_id
}

resource "yandex_vpc_subnet" "net" {
  zone           = var.zone
  network_id     = resource.yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.10.0.0/24"]
  folder_id      = var.folder_id
}
resource "local_file" "inventory" {
  content = <<-EOT
  [web]  
  ${join("\n", [for instance in yandex_compute_instance.instance : "${coalesce(instance.network_interface[0].nat_ip_address, instance.network_interface[0].ip_address)} ansible_user=${var.ssh_user}"])}

  EOT
  filename = "${path.module}/../ansible/inventory.ini"
}

resource "yandex_vpc_security_group" "sg1" {
  name        = "my_security_group"
  description = "description for my security group"
  folder_id   = var.folder_id
  network_id  = resource.yandex_vpc_network.net.id

  labels = {
    my-label = "my-label-value"
  }

  dynamic "ingress" {
    for_each = flatten(local.service_ports)
    content {
      protocol       = "TCP"
      port           = ingress.value
      v4_cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}