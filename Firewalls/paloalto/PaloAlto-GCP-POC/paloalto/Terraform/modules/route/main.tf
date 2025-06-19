resource "google_compute_route" "route" {
  for_each = var.routes
  project      = var.project_id
  name         = each.key
  network      = each.value.network_name
  dest_range   = each.value.dest_range
  next_hop_ip  = each.value.next_hop_ip
  priority     = each.value.priority
  tags         = each.value.tags
}
