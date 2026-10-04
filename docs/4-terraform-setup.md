# 🏗️ 04 — Terraform Import Setup

This document explains how Terraform was added after the infrastructure already existed in AWS.

---

## 🧭 Documentation Path

```text
01 Manual EC2 + Nginx setup
   -> 02 Ansible automation
   -> 03 Monitoring setup
   -> 04 Terraform import setup  ← you are here
```

This phase connects the already-running AWS infrastructure back into code and generates inventory for Ansible.

Previous: [03 — Monitoring Setup](./3-monitoring-setup.md)

Project overview: [Main README](../README.md)

---

## 🧩 Overview

The project started with a manually created EC2 instance. Instead of deleting and recreating that infrastructure, Terraform was introduced using an import workflow.

This is useful because many real environments already have resources running before Infrastructure as Code is introduced.

## 🛠️ What Terraform Manages

Current Terraform coverage:

- Ubuntu EC2 instance
- security group
- EC2 public IP output
- generated Ansible inventory

Terraform also creates `ansible-project/inventory.generated.ini`, which connects the infrastructure step to the Ansible automation step.

## 🔁 Workflow

```text
Manual AWS infrastructure
  -> configure AWS CLI
  -> write Terraform resource blocks
  -> import existing AWS resources
  -> validate Terraform state
  -> generate Ansible inventory
  -> run Ansible playbooks
```

## ⚙️ Prerequisites

- Terraform installed locally
- AWS CLI installed locally
- AWS IAM access key and secret access key
- existing EC2 instance and security group in AWS
- SSH key available locally for Ansible access

## 🔐 AWS CLI Authentication

AWS CLI was configured locally using access keys:

```bash
aws configure
```

The command prompts for:

```text
AWS Access Key ID
AWS Secret Access Key
Default region name
Default output format
```

Important: access keys should never be committed to the repository. They should stay in the local AWS CLI config or be managed through a secure credentials workflow.

## 🗂️ Terraform Files

| File | Purpose |
|------|---------|
| `terraform/provider.tf` | AWS provider and region |
| `terraform/main.tf` | EC2, security group, output, and generated inventory |
| `terraform/terraform.tfvars` | Local variable values |
| `terraform/.terraform.lock.hcl` | Provider lock file |

## 🚀 Import Flow

Move into the Terraform directory:

```bash
cd terraform
```

Initialize Terraform:

```bash
terraform init
```

Write matching Terraform resource blocks before importing. Terraform needs the resource names in code before it can connect them to existing AWS resources.

Example import commands:

```bash
terraform import aws_instance.demo <instance-id>
terraform import aws_security_group.web_sg <security-group-id>
```

After import, verify the state:

```bash
terraform state list
terraform plan
```

The goal is for Terraform to recognize the existing infrastructure without trying to recreate it.

## 🔗 Generating Ansible Inventory

The `local_file` resource in `terraform/main.tf` generates:

```text
../ansible-project/inventory.generated.ini
```

The generated inventory contains both groups required by Ansible:

```ini
[web_servers]
<public-ip> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/your-key.pem

[monitoring]
<public-ip> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/your-key.pem
```

In this project, both groups point to the same Ubuntu EC2 instance.

## ▶️ Run Terraform

Validate the configuration:

```bash
terraform validate
```

Preview changes:

```bash
terraform plan
```

Apply changes when ready:

```bash
terraform apply
```

After apply, run Ansible with the generated inventory:

```bash
ansible-playbook -i ansible-project/inventory.generated.ini ansible-project/playbook.yml
ansible-playbook -i ansible-project/inventory.generated.ini ansible-project/monitoring.yml
```

Run those commands from the repository root.

## 🧹 Files Ignored By Git

The repo ignores generated or machine-specific Terraform/Ansible files:

```text
terraform/.terraform/
terraform/*.tfstate
terraform/*.tfstate.backup
ansible-project/inventory.generated.ini
ansible-project/inventory.ini
```

This keeps real infrastructure details and local machine output out of version control.

## 🧭 Current Project Flow

This Terraform stage connects the earlier project phases:

1. Manual EC2 setup proved the baseline
2. Ansible automated server configuration
3. Monitoring added visibility
4. Terraform imported the existing infrastructure and generates inventory for Ansible

Next planned improvements are Docker and CI/CD.

---

## 🧭 End Of Current Series

This completes the current documentation path:

```text
Manual setup -> Ansible automation -> Monitoring -> Terraform import
```

>📚 This file is part of the documentation series under /docs/
Back to project overview: [Main README](../README.md)
