# Creates Google Compute Subnetworks.
# The lifecycle block is static to conform to HCL rules.
resource "google_compute_subnetwork" "subnet" {
  for_each = var.subnets

  project                  = var.project_id
  name                     = each.key
  region                   = var.region
  network                  = each.value.network_self_link
  ip_cidr_range            = each.value.ip_cidr_range
  description              = each.value.description
  private_ip_google_access = each.value.private_ip_google_access

  lifecycle {
    create_before_destroy = true
  }
}
