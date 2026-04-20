# OCI Server Provisioning with Terraform & Ansible

Automates provisioning of a hardened OCI compute instance with **Terraform**, configures the OS and deploys **WireGuard (wg-easy)** + **Dozzle agent** via **Ansible**, orchestrated through **GitHub Actions**.

---

> **Disclaimer**
> Educational project, not production-ready.
> The main goal is learning IaC, OCI, WireGuard, and Docker orchestration.

---

## Overview

- Provisions an OCI compute instance (default: `VM.Standard.A1.Flex`, 4 OCPUs / 24 GB — Always Free tier)
- Creates VCN, subnet, internet gateway, and a security list exposing only SSH and WireGuard UDP publicly
- Installs Docker, zsh + oh-my-zsh + fastfetch, fail2ban, unattended-upgrades
- Disables SSH password auth and root login
- Runs **wg-easy v15** (WireGuard + web UI, tunnel-only access)
- Runs **Dozzle agent** for remote log viewing over the VPN

## Prerequisites

### OCI Account
- Free tier account: https://www.oracle.com/cloud/free/
- Create an API user with permissions to manage compute and networking
- Generate an API key and note the fingerprint

### Remote State
- Create an OCI Object Storage bucket for Terraform state
- Update `providers.tf` with your `bucket` name and `namespace`

### SSH Key
```
ssh-keygen -t rsa -b 4096 -f mykey
```
Store both keys in GitHub Secrets (see table below).

## Environment Variables

GitHub **Secrets** (sensitive) and **Variables** (non-sensitive):

| Variable | Type | Description |
|----------|------|-------------|
| `TF_VAR_availability_domain` | Variable | OCI availability domain |
| `TF_VAR_compartment_id` | Secret | OCI compartment OCID |
| `TF_VAR_shape` | Variable | Instance shape (e.g., `VM.Standard.A1.Flex`) |
| `TF_VAR_display_name` | Variable | Instance display name |
| `TF_VAR_region` | Variable | OCI region |
| `TF_VAR_ssh_public_key` | Secret | SSH public key content |
| `TF_VAR_ssh_private_key` | Secret | SSH private key (used by Ansible) |
| `TF_VAR_source_image_id` | Secret | Base image OCID (use ARM image for A1.Flex) |
| `TF_VAR_tenancy_ocid` | Secret | OCI tenancy OCID |
| `TF_VAR_user_ocid` | Secret | OCI user OCID |
| `TF_VAR_fingerprint` | Secret | API key fingerprint |
| `TF_VAR_private_key` | Secret | OCI API private key |
| `WG_PASSWORD` | Secret | Admin password for wg-easy UI |

Optional overrides (all have defaults):
- `TF_VAR_ssh_allowed_source_cidr` — lock SSH to your IP/32
- `TF_VAR_wg_allowed_source_cidr` — lock WG UDP to your IP/32
- `TF_VAR_ocpus`, `TF_VAR_memory_in_gbs` — for flex shape sizing

## Getting Started

1. Fork the repo
2. Configure GitHub Secrets and Variables per the table above
3. Update `providers.tf` with your bucket and namespace
4. Push to `main` — the pipeline runs validate → plan → apply (manual approval) → Ansible configure

## Accessing Services

All services are bound to VPN-only interfaces for security:

### wg-easy UI
Access via SSH tunnel (recommended for initial client setup):
```
ssh -L 51821:localhost:51821 ubuntu@<instance-ip>
```
Then open `http://localhost:51821` — login with `admin` / your `WG_PASSWORD`.

Or via WireGuard once connected: `http://10.8.0.1:51821`

### Dozzle Agent
Reachable at `10.8.0.1:7007` once connected to the VPN. Configure your local Dozzle instance to use this as a remote agent:
```yaml
environment:
  - DOZZLE_REMOTE_AGENT=10.8.0.1:7007
```

## Running Locally

```
source .env
terraform init -backend-config="region=$TF_VAR_region" \
  -backend-config="tenancy_ocid=$TF_VAR_tenancy_ocid" \
  -backend-config="user_ocid=$TF_VAR_user_ocid" \
  -backend-config="fingerprint=$TF_VAR_fingerprint" \
  -backend-config="private_key=$TF_VAR_private_key"
terraform apply
```

Ansible (requires `WG_PASSWORD` and `ANSIBLE_HOST` env vars):
```
ANSIBLE_HOST=$(terraform output -raw instance_public_ip) \
WG_HOST=$(terraform output -raw instance_public_ip) \
ansible-playbook -i ansible/inventory.yml ansible/playbook.yml
```
