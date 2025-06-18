# FortiGate address object configuration template
# This template creates a firewall address object for a web server.
config firewall address
  edit "web-server"
    set subnet ${web_server_ip} 255.255.255.255
  next
end
