
Palo Alto VM-Series on GCP: Setup and Verification Guide

This guide provides a complete, step-by-step process for deploying and testing the Palo Alto VM-Series firewall using the provided Terraform codebase.

Step 1: Prerequisites

Google Cloud SDK: Ensure you have gcloud installed and configured.

Generated bash
gcloud auth login
gcloud auth application-default login
gcloud config set project [YOUR_GCP_PROJECT_ID]
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Bash
IGNORE_WHEN_COPYING_END

Terraform: Ensure you have Terraform v1.0 or newer installed.

Enable APIs: Make sure the Compute Engine API is enabled in your project.

Generated bash
gcloud services enable compute.googleapis.com
IGNORE_WHEN_COPYING_START
content_copy
download
Use code with caution.
Bash
IGNORE_WHEN_COPYING_END
Step 2: Configuration

Navigate to the dev environment directory:

Generated bash
cd paloalto/Terraform/environments/dev```

Open the `terraform.tfvars` file. You must configure two variables:

1.  **`pan_admin_password`**: Set a strong password for the `admin` user on the firewall.
    ```tfvars
    # Example:
    pan_admin_password = "MySecureP@ssw0rd123!"
    ```

2.  **`bootstrap_bucket_name`**: This **must be a globally unique name**. A good practice is to append a random number or your project ID.
    ```tfvars
    # Example:
    bootstrap_bucket_name = "pan-bootstrap-poc-vc-dev-lab-9876"
    ```

---

## Step 3: Deployment

1.  **Initialize Terraform:**
    ```bash
    terraform init
    ```
2.  **Review the Plan:**
    ```bash
    terraform plan
    ```
3.  **Apply the Configuration:** This will create all the resources. The Palo Alto VM may take 5-10 minutes to boot and bootstrap fully.
    ```bash
    terraform apply -auto-approve
    ```

---

## Step 4: Post-Deployment Verification & Configuration

This is the most critical part. Unlike the FortiGate, the Palo Alto firewall's default policy is to **deny all traffic**. You must manually create policies to allow traffic to flow.

### 4.1. Log in to the Palo Alto GUI (PAN-OS)

1.  **Get the Public IP:** From the `terraform apply` output, find the `paloalto_vm_details`.
2.  **Navigate:** Open a browser and go to `https://<YOUR_PALO_ALTO_PUBLIC_IP>`. Accept the self-signed certificate warning.
3.  **Credentials:**
    *   **Username:** `admin`
    *   **Password:** The `pan_admin_password` you set in your `.tfvars` file.

### 4.2. Verify Interfaces

1.  Go to the **Network** tab.
2.  In the left pane, click **Interfaces > Ethernet**.
3.  You should see that `ethernet1/1` and `ethernet1/2` have received IP addresses via DHCP from GCP. `ethernet1/1` will be your external (untrust) interface, and `ethernet1/2` will be your internal (trust) interface.

### 4.3. Create Security & NAT Policies (CRITICAL STEP)

You must create two rules to allow your test VM to reach the internet.

#### **A. Create the Outbound NAT Policy**
This rule translates the private IP of your test VM to the public IP of the firewall.

1.  Go to the **Policies** tab.
2.  In the left pane, select **NAT**.
3.  Click **Add** at the bottom.
4.  In the **General** tab, give it a name like `Outbound-NAT`.
5.  In the **Original Packet** tab:
    *   **Source Zone:** Click **Add** and select `trust`.
    *   **Destination Zone:** Click **Add** and select `untrust`.
    *   **Destination Interface:** Select `ethernet1/1`.
6.  In the **Translated Packet** tab:
    *   **Translation Type:** Select `Dynamic IP And Port`.
    *   **Address Type:** Select `Interface Address`.
    *   **Interface:** Select `ethernet1/1`.
7.  Click **OK**.

#### **B. Create the Security Policy**
This rule allows traffic from the trust zone to the untrust zone.

1.  In the left pane, select **Security**.
2.  Click **Add** at the bottom.
3.  In the **General** tab, give it a name like `Allow-Trust-to-Untrust`.
4.  In the **Source** tab:
    *   **Source Zone:** Click **Add** and select `trust`.
5.  In the **Destination** tab:
    *   **Destination Zone:** Click **Add** and select `untrust`.
6.  In the **Actions** tab:
    *   **Action:** Ensure it is set to `Allow`.
7.  Click **OK**.

### 4.4. Commit Your Changes

This is the most important step in PAN-OS. Your changes are not active until you commit them.

1.  Click the **Commit** button in the top-right corner of the GUI.
2.  In the new window, click **Commit** again.
3.  Wait for the commit process to complete (1-2 minutes).

---

## Step 5: Test Your Setup

1.  **SSH into the Test VM:** Use the GCP console or `gcloud` to SSH into the `poc-test-vm`.
    ```bash
    gcloud compute ssh poc-test-vm --zone [your_zone]
    ```
2.  **Test Internet Connectivity:** From inside the test VM, run a `curl` command.
    ```bash
    curl -v https://www.google.com
    ```
    If you see a successful HTML response, your traffic is flowing correctly from the trust zone, through the Palo Alto firewall, and out to the internet!

3.  **View Logs:** Go back to the Palo Alto GUI, navigate to the **Monitor** tab, and you will see log entries for the traffic from your test VM, confirming that the firewall is inspecting the traffic.
