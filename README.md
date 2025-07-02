# 🚀 OCI Server Provisioning with Terraform

This project automates the deployment of a virtual machine on Oracle Cloud Infrastructure (OCI) using **Terraform**, installs **Docker**, and sets up containers automatically.

## 📦 Project Overview

- 🏗️ Provisions a VM instance (e.g. `VM.Standard.E2.1.Micro`)
- 🌐 Configures networking (VCN, Subnet)
- 🔐 Adds SSH access
- 🐳 Installs Docker
- 📦 Deploys containers automatically (e.g., via `cloud-init` or remote-exec)
- 🔄 GitHub Actions (coming soon) to apply Terraform automatically

---

## ✅ Prerequisites

- [Terraform](https://www.terraform.io/downloads)
- [OCI CLI](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)
- An [OCI Account](https://www.oracle.com/cloud/free/)
- An API Key configured for the CLI
- Your OCI credentials set up at `~/.oci/config`

---

## 🔧 Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/your-username/oci-server-iac.git
cd oci-server-iac
