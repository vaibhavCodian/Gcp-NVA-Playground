# ==============================================================================
# FortiGate Configuration Template

# This template uses `lookup()` and `if` directives to safely handle optional
# attributes, preventing "Unsupported attribute" errors. It works directly
# with the simplified `locals.tf` file.
# ==============================================================================

# --- System Interfaces ---
config system interface
%{ for iface in interfaces ~}
  edit "${iface.name}"
    set ip ${iface.ip}
    set allowaccess ${iface.allowaccess}
%{ if lookup(iface, "alias", null) != null ~}
    set alias "${iface.alias}"
%{ endif ~}
%{ if lookup(iface, "status", null) != null ~}
    set status ${iface.status}
%{ endif ~}
%{ if lookup(iface, "description", null) != null ~}
    set description "${iface.description}"
%{ endif ~}
  next
%{ endfor ~}
end

# --- Static Routing ---
config router static
%{ for route in static_routes ~}
  edit ${route.id}
    set gateway ${route.gateway}
    set device "${route.device}"
%{ if lookup(route, "distance", null) != null ~}
    set distance ${route.distance}
%{ endif ~}
%{ if lookup(route, "comment", null) != null ~}
    set comment "${route.comment}"
%{ endif ~}
  next
%{ endfor ~}
end

# --- Firewall Policies ---
config firewall policy
%{ for pol in firewall_policies ~}
  edit ${pol.id}
    set name "${pol.name}"
    set srcintf "${join(" ", pol.srcintf)}"
    set dstintf "${join(" ", pol.dstintf)}"
    set srcaddr "${join(" ", pol.srcaddr)}"
    set dstaddr "${join(" ", pol.dstaddr)}"
    set action ${pol.action}
    set schedule "${pol.schedule}"
    set service "${join(" ", pol.service)}"
    set nat ${pol.nat ? "enable" : "disable"}
%{ if lookup(pol, "logtraffic", null) != null ~}
    set logtraffic ${pol.logtraffic}
%{ endif ~}
%{ if lookup(pol, "status", null) != null ~}
    set status ${pol.status}
%{ endif ~}
%{ if lookup(pol, "comments", null) != null ~}
    set comments "${pol.comments}"
%{ endif ~}
  next
%{ endfor ~}
end

# --- Admin Users ---
%{ if length(admin_users) > 0 ~}
config system admin
%{ for user in admin_users ~}
  edit "${user.name}"
    set password ${user.password}
    set accprofile "${user.accprofile}"
%{ if lookup(user, "vdom", null) != null ~}
    set vdom "${user.vdom}"
%{ endif ~}
%{ if lookup(user, "comments", null) != null ~}
    set comments "${user.comments}"
%{ endif ~}
  next
%{ endfor ~}
end
%{ endif ~}

# --- DNS Settings ---
%{ if dns != null ~}
config system dns
  set primary ${dns.primary}
  set secondary ${dns.secondary}
%{ if lookup(dns, "domain", null) != null ~}
  set domain "${dns.domain}"
%{ endif ~}
end
%{ endif ~}

# --- NTP Settings ---
%{ if length(ntp_servers) > 0 ~}
config system ntp
  set ntpsync enable
  set type custom
%{ for ntp in ntp_servers ~}
  config ntpserver
    edit ${ntp.id}
      set server "${ntp.server}"
    next
  end
%{ endfor ~}
end
%{ endif ~}

# --- Firewall Address Objects ---
%{ if length(address_objects) > 0 ~}
config firewall address
%{ for addr in address_objects ~}
  edit "${addr.name}"
    set subnet ${addr.subnet}
%{ if lookup(addr, "comment", null) != null ~}
    set comment "${addr.comment}"
%{ endif ~}
  next
%{ endfor ~}
end
%{ endif ~}

# --- Firewall VIPs ---
%{ if length(vips) > 0 ~}
config firewall vip
%{ for vip in vips ~}
  edit "${vip.name}"
    set extip ${vip.extip}
    set mappedip "${vip.mappedip}"
%{ if lookup(vip, "comment", null) != null ~}
    set comment "${vip.comment}"
%{ endif ~}
  next
%{ endfor ~}
end
%{ endif ~}

# --- Firewall VIP Groups ---
%{ if length(vip_groups) > 0 ~}
config firewall vipgrp
%{ for grp in vip_groups ~}
  edit "${grp.name}"
    set member "${join(" ", grp.members)}"
%{ if lookup(grp, "comment", null) != null ~}
    set comment "${grp.comment}"
%{ endif ~}
  next
%{ endfor ~}
end
%{ endif ~}

# --- Firewall Service Groups ---
%{ if length(service_groups) > 0 ~}
config firewall service group
%{ for svc in service_groups ~}
  edit "${svc.name}"
    set member "${join(" ", svc.members)}"
%{ if lookup(svc, "comment", null) != null ~}
    set comment "${svc.comment}"
%{ endif ~}
  next
%{ endfor ~}
end
%{ endif ~}

# --- System Zones ---
%{ if length(zones) > 0 ~}
config system zone
%{ for zone in zones ~}
  edit "${zone.name}"
    set interface "${join(" ", zone.interface)}"
%{ if lookup(zone, "comment", null) != null ~}
    set comment "${zone.comment}"
%{ endif ~}
  next
%{ endfor ~}
end
%{ endif ~}

# --- High Availability (HA) ---
%{ if ha != null ~}
config system ha
  set mode ${ha.mode}
  set password ${ha.password}
  set group-id ${ha.group_id}
  set priority ${ha.priority}
  set hbdev "${join(" ", ha.hbdev)}"
  set session-pickup ${ha.session_pickup ? "enable" : "disable"}
end
%{ endif ~}

# --- Log Settings ---
%{ if log_settings != null ~}
config log syslogd setting
  set status enable
  set server "${log_settings.syslog_server}"
  set port ${log_settings.syslog_port}
%{ if lookup(log_settings, "log_level", null) != null ~}
  set loglevel ${log_settings.log_level}
%{ endif ~}
end
%{ endif ~}

# --- SNMP Settings ---
%{ if snmp != null ~}
config system snmp community
  edit 1
    set name "${snmp.community}"
    set hosts "${join(" ", snmp.hosts)}"
%{ if lookup(snmp, "status", null) != null ~}
    set status ${snmp.status}
%{ endif ~}
  next
end
%{ endif ~}

# --- RADIUS Servers ---
%{ if length(radius_servers) > 0 ~}
config user radius
%{ for radius in radius_servers ~}
  edit "${radius.name}"
    set server ${radius.server}
    set secret ${radius.secret}
%{ if lookup(radius, "port", null) != null ~}
    set port ${radius.port}
%{ endif ~}
%{ if lookup(radius, "status", null) != null ~}
    set status ${radius.status}
%{ endif ~}
  next
%{ endfor ~}
end
%{ endif ~}

# --- Custom Sections (for future use) ---
%{ if length(custom_sections) > 0 ~}
%{ for section in custom_sections ~}
${section}
%{ endfor ~}
%{ endif ~}