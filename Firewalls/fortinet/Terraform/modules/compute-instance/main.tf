# Creates Google Compute Engine instances.
# The lifecycle block is static to conform to HCL rules.
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
      dynamic "access_config" {
        for_each = network_interface.value.nat ? [1] : []
        content {}
      }
    }
  }

  metadata = each.value.metadata

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      # This prevents Terraform from re-creating the instance if the
      # startup-script metadata changes after initial creation.
      metadata.startup-script,
    ]
  }
}
