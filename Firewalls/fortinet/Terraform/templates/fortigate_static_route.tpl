# FortiGate static route configuration template
# This template creates a static route for a specific subnet.
config router static
  edit 10
    set dst ${static_route_subnet}
    set gateway ${static_route_gateway}
    set device "port2"
  next
end
