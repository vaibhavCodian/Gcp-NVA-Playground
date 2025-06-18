# FortiGate firewall policy configuration template
# This template creates a custom firewall policy.
config firewall policy
  edit 10
    set name "allow-web-to-db"
    set srcintf "port2"
    set dstintf "port3"
    set srcaddr "web-server"
    set dstaddr "db-server"
    set action accept
    set schedule "always"
    set service "MYSQL"
    set nat disable
  next
end
