output "subnet_self_links" {
  value = { for k, v in google_compute_subnetwork.subnet : k => v.self_link }
}
output "subnet_internal_ips" {
  value = { for k, v in google_compute_subnetwork.subnet : k => v.gateway_address }
}
