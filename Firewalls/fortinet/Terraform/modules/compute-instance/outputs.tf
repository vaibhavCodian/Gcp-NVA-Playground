output "instance_details" {
  description = "Details of the created compute instances, including IP addresses."
  value = { for k, v in google_compute_instance.instance : k => {
    name           = v.name
    instance_id    = v.instance_id
    machine_type   = v.machine_type
    internal_ips   = [for nic in v.network_interface : nic.network_ip]
    external_ips   = [for nic in v.network_interface : try(nic.access_config[0].nat_ip, null)]
  }}
  sensitive = false
}
