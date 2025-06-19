output "vpc_self_links" {
  description = "The self-links of the created VPCs."
  value       = { for k, v in google_compute_network.vpc : k => v.self_link }
}
output "vpc_names" {
  description = "The names of the created VPCs."
  value       = { for k, v in google_compute_network.vpc : k => v.name }
}
output "vpc_ids" {
  description = "The IDs of the created VPCs."
  value       = { for k, v in google_compute_network.vpc : k => v.id }
}
