# Creates Google Compute Networks (VPCs).
# The lifecycle block is static to conform to HCL rules.
resource "google_compute_network" "vpc" {
  for_each = var.vpcs

  project                         = var.project_id
  name                            = each.key
  description                     = each.value.description
  auto_create_subnetworks         = each.value.auto_create_subnetworks
  routing_mode                    = each.value.routing_mode
  delete_default_routes_on_create = each.value.delete_default_routes_on_create
  mtu                             = each.value.mtu

  lifecycle {
    create_before_destroy = true
  }
}
