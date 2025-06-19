output "firewall_names" {
  value = [for k, v in google_compute_firewall.firewall : v.name]
}
