output "route_names" {
  value = [for k, v in google_compute_route.route : v.name]
}
