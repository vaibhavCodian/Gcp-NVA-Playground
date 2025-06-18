# FortiGate initial configuration template for startup script.
# Variables are injected by the templatefile() function in Terraform.
config system interface
  edit "port1"
    set mode dhcp
    set allowaccess ping https ssh
  next
  edit "port2"
    set ip ${internal_ip_with_mask}
    set allowaccess ping https ssh
  next
end

config router static
  edit 1
    set gateway ${default_gateway_ip}
    set device "port1"
  next
end

config firewall policy
  edit 1
    set name "allow-internal-to-internet"
    set srcintf "port2"
    set dstintf "port1"
    set srcaddr "all"
    set dstaddr "all"
    set action accept
    set schedule "always"
    set service "ALL"
    set nat enable
  next
end
