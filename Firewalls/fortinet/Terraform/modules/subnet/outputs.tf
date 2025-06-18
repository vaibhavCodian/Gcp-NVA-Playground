output "subnet_self_links" {
  description = "The self-links of the created subnets, keyed by their names."
  value       = { for k, v in google_compute_subnetwork.subnet : k => v.self_link }
}
