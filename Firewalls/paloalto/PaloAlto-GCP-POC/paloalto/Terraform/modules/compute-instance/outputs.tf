output "instance_details" {
  description = "Details of the created compute instances."
  value = { for k, v in google_compute_instance.instance : k => {
    name           = v.name
    instance_id    = v.instance_id
    external_ips   = [for nic in v.network_interface : try(nic.access_config[0].nat_ip, null)]
    internal_ips   = [for nic in v.network_interface : v.network_ip]
  }}
}
