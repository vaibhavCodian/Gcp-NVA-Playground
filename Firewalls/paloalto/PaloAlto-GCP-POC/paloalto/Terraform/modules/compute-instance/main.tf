resource "google_compute_instance" "instance" {
  for_each = var.instances
  project        = var.project_id
  zone           = var.zone
  name           = each.key
  machine_type   = each.value.machine_type
  tags           = each.value.tags
  can_ip_forward = each.value.can_ip_forward

  boot_disk {
    initialize_params {
      image = each.value.boot_disk.image
      size  = each.value.boot_disk.size
      type  = each.value.boot_disk.type
    }
  }

  dynamic "network_interface" {
    for_each = each.value.network_interfaces
    content {
      subnetwork = network_interface.value.subnet_self_link
      network_ip = lookup(network_interface.value, "internal_ip", null)
      dynamic "access_config" {
        for_each = network_interface.value.nat ? [1] : []
        content {}
      }
    }
  }

  metadata = each.value.metadata

  service_account {
    email  = each.value.service_account_email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [metadata]
  }
}
