# FortiGate admin user configuration template
# This template creates an additional admin user for FortiGate.
config system admin
  edit "devops"
    set password ${admin_password}
    set accprofile "super_admin"
  next
end
