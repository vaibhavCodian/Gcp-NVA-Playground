# Creates Google Compute Firewall rules.
# The lifecycle block is static to conform to HCL rules.
resource "google_compute_firewall" "firewall" {
  for_each = var.firewall_rules

  project       = var.project_id
  name          = each.key
  network       = var.network_name
  description   = each.value.description
  direction     = each.value.direction
  priority      = each.value.priority
  source_ranges = each.value.source_ranges
  target_tags   = each.value.target_tags

  dynamic "allow" {
    for_each = each.value.allow
    content {
      protocol = allow.value.protocol
      ports    = lookup(allow.value, "ports", null)
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
