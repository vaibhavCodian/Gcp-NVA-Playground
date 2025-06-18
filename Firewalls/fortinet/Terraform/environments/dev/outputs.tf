output "fortigate_vm_details" {
  description = "Details of the deployed FortiGate VM. The initial password for the 'admin' user is the 'instance_id'."
  value       = module.fortigate_instance.instance_details
}

output "next_steps" {
  description = "Instructions for accessing the FortiGate appliance."
  value = "Navigate to https://<EXTERNAL_IP>/. Use username 'admin' and the 'instance_id' from the output above as the initial password."
}
