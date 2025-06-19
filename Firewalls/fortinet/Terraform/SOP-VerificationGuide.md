# FortiGate NVA Configuration Verification Guide

This document provides a detailed, step-by-step guide to verify that all configurations defined in your Terraform files have been successfully applied to the FortiGate Network Virtual Appliance (NVA) after deployment. Each section corresponds to a block in your `fortigate_config.auto.tfvars` file.

## Table of Contents

1.  [**Logging In**](#step-1-logging-in-to-the-fortigate-web-admin-console)
2.  [**Network Interfaces** (`interfaces`)](#step-2-verify-network-interfaces)
3.  [**Static Routes** (`static_routes`)](#step-3-verify-static-routes)
4.  [**Firewall Policies** (`firewall_policies`)](#step-4-verify-firewall-policies)
5.  [**Admin Users** (`admin_users`)](#step-5-verify-admin-users)
6.  [**DNS Settings** (`dns`)](#step-6-verify-dns-settings)
7.  [**NTP Servers** (`ntp_servers`)](#step-7-verify-ntp-servers)
8.  [**Address Objects** (`address_objects`)](#step-8-verify-firewall-address-objects)
9.  [**Virtual IPs (VIPs)** (`vips`)](#step-9-verify-virtual-ips-vips)
10. [**System Zones** (`zones`)](#step-10-verify-system-zones)
11. [**High Availability (HA)** (`ha`)](#step-11-verify-high-availability-ha)
12. [**Log & Report Settings** (`log_settings`)](#step-12-verify-log--report-settings)
13. [**SNMP Settings** (`snmp`)](#step-13-verify-snmp-settings)
14. [**RADIUS Servers** (`radius_servers`)](#step-14-verify-radius-servers)

---

### Step 1: Logging In to the FortiGate Web Admin Console

Before you can verify the configuration, you need to access the FortiGate's management interface.

1.  **Get Credentials from Terraform Output:**
    *   After a successful `terraform apply`, look for the `fortigate_vm_details` output in your terminal.
    *   **Public IP Address:** This is the IP address listed under `external_ips`.
    *   **Initial Password:** This is the long number listed as the `instance_id`.

2.  **Navigate and Log In:**
    *   Open a web browser and go to `https://<YOUR_PUBLIC_IP>`.
    *   Accept the browser's security warning (this is expected for a new device with a self-signed certificate).
    *   **Username:** `admin`
    *   **Password:** The `instance_id` you copied.
    *   You will be forced to change the password. Choose a new, secure password.

You are now logged into the FortiGate dashboard and can begin verification.

---

### Step 2: Verify Network Interfaces

*   **Applied From:** `fortigate_config.auto.tfvars` > `interfaces`
*   **Purpose (Layman's Terms):** This section sets up the "plugs" or network ports on your virtual firewall. It assigns an IP address to each port so it can talk to different networks and specifies which services (like the web login page or SSH) can be accessed on that port.
*   **Where to Find It:** On the left menu, go to **Network > Interfaces**.

| Parameter | What to Look For in the UI | Explanation |
| :--- | :--- | :--- |
| **`port1`** | The row for `port1` should be visible. | This is your external-facing or "untrust" port that connects to the internet. |
| `ip` | **IP/Netmask:** `10.10.1.10/255.255.255.0` | The static IP address assigned to this port. |
| `allowaccess` | **Administrative Access:** `HTTPS`, `PING`, `SSH`, `HTTP`, `FGFM` | The management protocols allowed on this interface. |
| `alias` | **Alias:** `WAN` | A friendly name to easily identify this interface's purpose. |
| **`port2`** | The row for `port2` should be visible. | This is your internal-facing or "trust" port that connects to your private application servers. |
| `ip` | **IP/Netmask:** `10.10.2.10/255.255.255.0` | The static IP address assigned to this port. |
| `allowaccess` | **Administrative Access:** `HTTPS`, `PING`, `SSH` | The management protocols allowed on this interface. |
| `alias` | **Alias:** `LAN` | A friendly name to easily identify this interface's purpose. |

---

### Step 3: Verify Static Routes

*   **Applied From:** `fortigate_config.auto.tfvars` > `static_routes`
*   **Purpose (Layman's Terms):** This is the firewall's GPS. A static route tells the firewall where to send traffic when it doesn't know the specific destination. The "default route" (`0.0.0.0/0`) tells it to send all unknown traffic to the main internet gateway.
*   **Where to Find It:** On the left menu, go to **Network > Static Routes**.

| Parameter | What to Look For in the UI | Explanation |
| :--- | :--- | :--- |
| `id: 1` | A route will be listed (usually with #1). | The unique identifier for this route. |
| `gateway` | **Gateway Address:** `10.10.1.1` | The IP address of the next router to send the traffic to. |
| `device` | **Interface:** `port1` | The traffic will be sent out of this physical/virtual port. |
| `comment` | **Comment:** `Default route to Internet` | A note explaining what the route is for. |

---

### Step 4: Verify Firewall Policies

*   **Applied From:** `fortigate_config.auto.tfvars` > `firewall_policies`
*   **Purpose (Layman's Terms):** This is the main rulebook for the firewall. This specific policy allows devices on your internal network (LAN) to access the internet (WAN). It also enables NAT, which hides your internal device IPs behind the firewall's single public IP.
*   **Where to Find It:** On the left menu, go to **Policy & Objects > Firewall Policy**.

| Parameter | What to Look For in the UI | Explanation |
| :--- | :--- | :--- |
| `id: 1` | A policy with ID `1` will be listed. | The unique identifier for this policy. |
| `name` | **Name:** `Allow-Internal-to-Internet` | A friendly name for the policy. |
| `srcintf` | **Incoming Interface:** `port2` | Traffic that originates from this interface will match this rule. |
| `dstintf` | **Outgoing Interface:** `port1` | Traffic that is destined for this interface will match this rule. |
| `srcaddr`, `dstaddr` | **Source / Destination:** `all / all` | Specifies which IP addresses are allowed (in this case, any). |
| `action` | **Action:** `ACCEPT` | The action to take on matching traffic (allow it through). |
| `nat` | **NAT:** An icon indicating it's enabled. | Hides the source IP address behind the firewall's public IP. |
| `comments` | Hover over the policy name to see the comment. | `Default outbound policy for LAN traffic` |

---

### Step 5: Verify Admin Users

*   **Applied From:** `fortigate_config.auto.tfvars` > `admin_users`
*   **Purpose (Layman's Terms):** Creates an extra login account with full administrative privileges, separate from the default `admin` account.
*   **Where to Find It:** On the left menu, go to **System > Administrators**.

| Parameter | What to Look For in the UI | Explanation |
| :--- | :--- | :--- |
| `name` | **Name:** `devops` | The username for the new administrator. |
| `accprofile` | **Administrator Profile:** `super_admin` | The permission level for this user (full access). |
| `comments` | **Comments:** `Admin user for DevOps team` | A note explaining who this account is for. |

---

### Step 6: Verify DNS Settings

*   **Applied From:** `fortigate_config.auto.tfvars` > `dns`
*   **Purpose (Layman's Terms):** Sets the "phone book" that the firewall itself uses to look up internet domain names (like `google.com`).
*   **Where to Find It:** On the left menu, go to **Network > DNS**.

| Parameter | What to Look For in the UI | Explanation |
| :--- | :--- | :--- |
| `primary` | **Primary DNS Server:** `8.8.8.8` | The first server the firewall will ask for a name lookup. |
| `secondary` | **Secondary DNS Server:** `8.8.4.4` | The backup server if the first one doesn't respond. |

---

### Step 7: Verify NTP Servers

*   **Applied From:** `fortigate_config.auto.tfvars` > `ntp_servers`
*   **Purpose (Layman's Terms):** Sets the "time servers" that the firewall uses to keep its internal clock accurate. This is crucial for logging and security certificates.
*   **Where to Find It:** On the left menu, go to **System > Settings**. Under the **System Time** section.

| Parameter | What to Look For in the UI | Explanation |
| :--- | :--- | :--- |
| `ntpsync` | **Synchronize with NTP Server** should be enabled. | Tells the FortiGate to get its time from the internet. |
| `server` | The NTP server list should contain `time.google.com` and `pool.ntp.org`. | The specific time servers to use. |

---

### Step 8: Verify Firewall Address Objects

*   **Applied From:** `fortigate_config.auto.tfvars` > `address_objects`
*   **Purpose (Layman's Terms):** Creates a named shortcut for an IP address. Instead of typing `10.10.2.100` in a policy, you can just use the name `webserver_private_ip`, which is easier to read and manage.
*   **Where to Find It:** On the left menu, go to **Policy & Objects > Addresses**.

| Parameter | What to Look For in the UI | Explanation |
| :--- | :--- | :--- |
| `name` | **Name:** `webserver_private_ip` | The custom name for this IP address object. |
| `subnet` | **IP/Netmask:** `10.10.2.100/32` | The IP address and subnet mask this name represents. |

---

### Step 9: Verify Virtual IPs (VIPs)

*   **Applied From:** `fortigate_config.auto.tfvars` > `vips`
*   **Purpose (Layman's Terms):** Creates a port forwarding rule. It maps an external IP address (on the WAN side) to an internal IP address (on the LAN side), allowing you to host a server behind the firewall.
*   **Where to Find It:** On the left menu, go to **Policy & Objects > Virtual IPs**.

| Parameter | What to Look For in the UI | Explanation |
| :--- | :--- | :--- |
| `name` | **Name:** `vip_webserver` | The name of this port forwarding rule. |
| `extip` | **External IP Address/Range:** `10.10.1.100` | The IP address on the outside that users will connect to. |
| `mappedip` | **Mapped IP Address/Range:** `10.10.2.100` | The internal IP address of the server that will receive the traffic. |

---

### Step 10: Verify System Zones

*   **Applied From:** `fortigate_config.auto.tfvars` > `zones`
*   **Purpose (Layman's Terms):** Groups multiple network ports into a single logical "zone". This lets you write one firewall policy for the "lan-zone" instead of writing separate policies for `port2`, `port3`, etc.
*   **Where to Find It:** On the left menu, go to **Network > Interfaces**. Click the **"Zone"** view button in the top toolbar.

| Parameter | What to Look For in the UI | Explanation |
| :--- | :--- | :--- |
| `name` | **Name:** `lan-zone` | The name of the logical grouping. |
| `interface` | **Members:** `port2` | The list of physical/virtual ports that belong to this zone. |

---

### Step 11: Verify High Availability (HA)

*   **Applied From:** `fortigate_config.auto.tfvars` > `ha`
*   **Purpose (Layman's Terms):** Configures the firewall to work with a backup partner. If this firewall fails, the backup takes over automatically.
*   **Where to Find It:** On the left menu, go to **System > HA**.

| Parameter | What to Look For in the UI | Explanation |
| :--- | :--- | :--- |
| `mode` | **Mode:** `Active-Passive` | One firewall is active, the other is on standby. |
| `priority` | **Device Priority:** `200` | A higher number means this device is more likely to be the primary. |
| `group-id` | **Group ID:** `10` | A number that must match on both HA partners. |
| `hbdev` | **Heartbeat Interfaces:** `port3` | The port used by the firewalls to check if each other is still alive. |

---

### Step 12: Verify Log & Report Settings

*   **Applied From:** `fortigate_config.auto.tfvars` > `log_settings`
*   **Purpose (Layman's Terms):** Tells the firewall to send a copy of its activity logs to a separate, central logging server (a syslog server) for storage and analysis.
*   **Where to Find It:** On the left menu, go to **Log & Report > Log Settings**.

| Parameter | What to Look For in the UI | Explanation |
| :--- | :--- | :--- |
| `status` | **Send Logs to Syslog:** Should be enabled. | The master switch to turn on remote logging. |
| `syslog_server` | **IP Address:** `10.10.2.200` | The IP address of the server receiving the logs. |
| `syslog_port` | **Port:** `514` | The network port used for the syslog protocol. |

---

### Step 13: Verify SNMP Settings

*   **Applied From:** `fortigate_config.auto.tfvars` > `snmp`
*   **Purpose (Layman's Terms):** Allows a network monitoring system to ask the firewall for health information, like CPU usage, memory, and network traffic statistics.
*   **Where to Find It:** On the left menu, go to **System > SNMP**.

| Parameter | What to Look For in the UI | Explanation |
| :--- | :--- | :--- |
| `status` | **SNMP Agent:** Should be enabled. | The master switch to turn on the SNMP service. |
| `community` | In the SNMP v1/v2c communities list, a community named `gcp_snmp_ro` should exist. | The "password" the monitoring system uses to access the data. |
| `hosts` | The hosts list for that community should contain `10.10.2.201`. | The IP address of the monitoring server allowed to query this firewall. |

---

### Step 14: Verify RADIUS Servers

*   **Applied From:** `fortigate_config.auto.tfvars` > `radius_servers`
*   **Purpose (Layman's Terms):** Configures the firewall to use an external RADIUS server to authenticate users (for example, for VPN logins), instead of using local accounts stored on the firewall itself.
*   **Where to Find It:** On the left menu, go to **User & Authentication > RADIUS Servers**.

| Parameter | What to Look For in the UI | Explanation |
| :--- | :--- | :--- |
| `name` | **Name:** `gcp_radius` | A friendly name for this RADIUS server connection. |
| `server` | **Primary Server IP/Name:** `10.10.2.202` | The IP address of the RADIUS server. |
| `port` | **Primary Server Port:** `1812` | The network port used for the RADIUS protocol. |