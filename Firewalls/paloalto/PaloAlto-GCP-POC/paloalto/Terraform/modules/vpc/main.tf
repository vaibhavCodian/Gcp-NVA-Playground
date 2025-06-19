resource "google_compute_network" "vpc" {
  for_each = var.vpcs
  project                 = var.project_id
  name                    = each.key
  description             = each.value.description
  auto_create_subnetworks = each.value.auto_create_subnetworks
  routing_mode            = each.value.routing_mode
  lifecycle {
    create_before_destroy = true
  }
}
