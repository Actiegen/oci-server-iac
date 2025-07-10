# 🚀 OCI Server Provisioning with Terraform

This project automates the provisioning of a virtual machine on Oracle Cloud Infrastructure (OCI) using **Terraform**, installs **Docker**, and sets up a **WireGuard VPN** container using **Ansible**.

---

> ⚠️ **Disclaimer**  
> This project is **not intended for production use by companies**.  
> The web interface is exposed with a password, **but without HTTPS encryption** on this particular exemple.  
>  
> The main purpose of this repository is **educational**, focused on:
> - Infrastructure as code (IaC)
> - Provisioning a VPN server (WireGuard) to establish a private network over the internet with 

---

## 📦 Project Overview

- 🏗️ Provisions a VM instance (e.g., `VM.Standard.E2.1.Micro`)
- 🌐 Configures networking (VCN, Subnet, Internet Gateway)
- 🔐 Enables secure SSH access using your own key pair
- 🐳 Installs Docker
- 📦 Automatically deploys containers
- 🤖 Automates provisioning via **GitHub Actions**
- 🔐 Runs a WireGuard VPN server

---

## ✅ Prerequisites

Before you can run this project, ensure the following are ready:

### ☁️ Oracle Cloud Infrastructure Account

- Create a free account: https://www.oracle.com/cloud/free/
- Set up your OCI credentials with the [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)
- Configure your CLI credentials in `~/.oci/config`
- Configure a User with permissions to create instances and network resources
- Configure an API Key for the User to be set up on the pipeline variables.

### 🪣 Remote State Storage (Terraform)

- Create an **Object Storage Bucket** in OCI to store Terraform state
- Update the `providers.tf` file with the following info:
  - Your bucket name
  - Your namespace

Example:
```hcl
backend "oci" {
  bucket = "my-tf-state"
  namespace = "my-namespace"
}
```

## 🔐 SSH Key Pair
Generate an SSH key pair and add both to GitHub:
```
ssh-keygen -t rsa -b 4096 -f mykey
```
- Add mykey (private) to GitHub Secrets as TF_VAR_ssh_private_key

- Add mykey.pub (public) to GitHub Secrets as TF_VAR_ssh_public_key

## 🔗 WireGuard Client Setup
Once you have the server up and running, you should be able access your instance public ip on port 51821 in your browser via HTTP

- Log in web console using the password provided on variables (see variables below).
- Click on the "+ New" button to generate a new client config file.

- Download the WireGuard client: [WireGuard Client for Windows/macOS/Linux](https://www.wireguard.com/install/)

- Import the generated config file into the WireGuard Desktop Client and click "Activate" to connect to the VPN Server.

🛠 Environment Variables
The project requires several environment variables (some as Secrets, others as Repository Variables) to function via GitHub Actions:

| Variable Name                 | Type      | Description                                                                 |
|------------------------------|-----------|-----------------------------------------------------------------------------|
| `TF_VAR_availability_domain` | Variable  | The OCI availability domain (e.g., `Uocm:PHX-AD-1`)                         |
| `TF_VAR_compartment_id`      | Secret    | Your OCI compartment OCID                                                  |
| `TF_VAR_shape`               | Variable  | The shape of the instance (e.g., `VM.Standard.E2.1.Micro`)                 |
| `TF_VAR_ssh_public_key`      | Secret    | Your SSH public key content                                                |
| `TF_VAR_source_image_id`     | Secret    | Image OCID for the base system                                             |
| `TF_VAR_display_name`        | Variable  | Name assigned to the compute instance                                      |
| `TF_VAR_namespace`           | Secret    | OCI Object Storage namespace                                               |
| `TF_VAR_tenancy_ocid`        | Secret    | Your OCI tenancy OCID                                                      |
| `TF_VAR_user_ocid`           | Secret    | Your OCI user OCID                                                         |
| `TF_VAR_fingerprint`         | Secret    | The fingerprint of your API key                                            |
| `TF_VAR_private_key`         | Secret    | Your OCI API private key (used by Terraform provider)                      |
| `TF_VAR_ssh_private_key`     | Secret    | The private key to access the provisioned instance                         |
| `TF_VAR_region`              | Variable  | The region where resources are provisioned (e.g., `us-ashburn-1`)          |
| `TF_VAR_auth`                | Variable  | Auth type for Terraform provider (`APIKey`)                                |
| `WG_PASSWORD`                | Secret    | Password to access WireGuard config or dashboard (if configured)           |

## 🚀 Getting Started
- Fork the repository
- Set the required GitHub Secrets and Variables on your new repo (see table above)
- Adjust the terraform/providers.tf backend block with your bucket info
- Push to the main branch — GitHub Actions will provision the infrastructure
