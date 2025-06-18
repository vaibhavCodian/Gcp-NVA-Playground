output "vpc_self_links" {
  description = "The self-links of the created VPCs, keyed by their names."
  value       = { for k, v in google_compute_network.vpc : k => v.self_link }
}

output "vpc_names" {
  description = "The names of the created VPCs, keyed by their names."
  value       = { for k, v in google_compute_network.vpc : k => v.name }
}
