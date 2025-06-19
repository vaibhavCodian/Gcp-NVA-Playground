fortigate_config = {
  interfaces = [
    {
      name        = "port1"
      ip          = "10.10.1.10 255.255.255.0"
      allowaccess = "ping https ssh http fgfm"
      alias       = "WAN"
      status      = "up"
      description = "External interface"
    },
    {
      name        = "port2"
      ip          = "10.10.2.10 255.255.255.0"
      allowaccess = "ping https ssh"
      alias       = "LAN"
      status      = "up"
      description = "Internal interface"
    }
  ]
  static_routes = [
    {
      id       = 1
      gateway  = "10.10.1.1"
      device   = "port1"
      distance = 10
      comment  = "Default route to Internet"
    }
  ]
  firewall_policies = [
    {
      id         = 1
      name       = "Allow-Internal-to-Internet"
      srcintf    = ["port2"]
      dstintf    = ["port1"]
      srcaddr    = ["all"]
      dstaddr    = ["all"]
      action     = "accept"
      schedule   = "always"
      service    = ["ALL"]
      nat        = true
      logtraffic = "all"
      status     = "enable"
      comments   = "Default outbound policy for LAN traffic"
    }
  ]
  admin_users = [
    {
      name       = "devops"
      password   = "ChangeMePlease123!"
      accprofile = "super_admin"
      vdom       = "root"
      comments   = "Admin user for DevOps team"
    }
  ]
  dns = {
    primary   = "8.8.8.8"
    secondary = "8.8.4.4"
    domain    = "gcp.example.com"
  }
  ntp_servers = [
    { id = 1, server = "time.google.com" },
    { id = 2, server = "pool.ntp.org" }
  ]
  address_objects = [
    {
      name    = "webserver_private_ip"
      subnet  = "10.10.2.100 255.255.255.255"
      comment = "Private IP for internal web server"
    }
  ]
  vips = [
    {
      name     = "vip_webserver"
      extip    = "10.10.1.100" # Example external IP on WAN
      mappedip = "10.10.2.100"
      comment  = "VIP for external access to webserver"
    }
  ]
  vip_groups = [
    {
      name    = "web_vips"
      members = ["vip_webserver"]
      comment = "Group of all web server VIPs"
    }
  ]
  service_groups = [
    {
      name    = "web_services"
      members = ["HTTP", "HTTPS"]
      comment = "Standard web services"
    }
  ]
  zones = [
    {
      name      = "lan-zone"
      interface = ["port2"]
      comment   = "Internal trusted zone"
    }
  ]
  ha = {
    mode           = "a-p"
    password       = "a_very_secret_ha_password"
    group_id       = 10
    priority       = 200
    hbdev          = ["port3"]
    session_pickup = true
  }
  log_settings = {
    syslog_server = "10.10.2.200"
    syslog_port   = 514
    log_level     = "information"
  }
  snmp = {
    community = "gcp_snmp_ro"
    hosts     = ["10.10.2.201"]
    status    = "enable"
  }
  radius_servers = [
    {
      name   = "gcp_radius"
      server = "10.10.2.202"
      secret = "a_very_secret_radius_key"
      port   = 1812
      status = "enable"
    }
  ]
}