output "firewall_names" {
  description = "The names of the created firewall rules."
  value       = [for k, v in google_compute_firewall.firewall : v.name]
}
