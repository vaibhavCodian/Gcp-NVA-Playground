output "paloalto_vm_details" {
  description = "Details of the deployed Palo Alto VM. Use the password from your .tfvars file."
  value       = module.paloalto_instance.instance_details
}
output "next_steps" {
  description = "Instructions for accessing the Palo Alto appliance."
  value       = "Navigate to https://<EXTERNAL_IP>/. Use username 'admin' and the password you set in terraform.tfvars."
}
output "test_vm_name" {
  description = "Name of the internal test VM to SSH into."
  value       = module.test_vm.instance_details["poc-test-vm"].name
}
