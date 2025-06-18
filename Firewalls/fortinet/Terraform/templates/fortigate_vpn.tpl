# FortiGate VPN configuration template
# This template creates a basic IPsec VPN configuration.
config vpn ipsec phase1-interface
  edit "vpn-to-branch"
    set interface "port1"
    set peertype any
    set net-device disable
    set proposal aes256-sha256
    set remote-gw ${remote_gateway_ip}
    set psksecret ${vpn_psk}
  next
end

config vpn ipsec phase2-interface
  edit "vpn-to-branch"
    set phase1name "vpn-to-branch"
    set proposal aes256-sha256
    set src-subnet ${local_subnet}
    set dst-subnet ${remote_subnet}
  next
end
