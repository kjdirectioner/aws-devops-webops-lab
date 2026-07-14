# 🏗️ 04 — Terraform Import Setup

This document explains how Terraform was added after the infrastructure already existed in AWS.

---

## 🧭 Documentation Path

```text
01 Manual EC2 + Nginx setup
   -> 02 Ansible automation
   -> 03 Monitoring setup
   -> 04 Terraform import setup  ← you are here
   -> 05 Manual network re-architecture
   -> 06 Terraform modular refactor
```

This phase connects the already-running AWS infrastructure back into code and generates inventory for Ansible.

Previous: [03 — Monitoring Setup](./3-monitoring-setup.md)

Next: [05 — Manual Network Re-Architecture](./5-manual-network-rearchitecture.md)

---

## 🧩 Overview

The project started with a manually created EC2 instance. Instead of deleting and recreating that infrastructure, Terraform was introduced using an import workflow.

This is useful because many real environments already have resources running before Infrastructure as Code is introduced.

## 🛠️ What Terraform Manages

Current Terraform coverage:

- Ubuntu EC2 instance
- custom security group attached to the instance
- EC2 public IP output
- generated Ansible inventory

Terraform also creates `ansible-project/inventory.generated.ini`, which connects the infrastructure step to the Ansible automation step.

## 🔁 Workflow

```text
Manual AWS infrastructure
  -> reconfigure AWS CLI credentials
  -> import existing EC2 instance
  -> sync Terraform config with real AWS state
  -> reach "No changes" in terraform plan
  -> replace hardcoding with variables and terraform.tfvars
  -> create and attach a custom security group
  -> close ports that are not needed publicly
  -> output the public IP
  -> pass Terraform output into Ansible
```

## ⚙️ Prerequisites

- Terraform installed locally
- AWS CLI installed locally
- AWS IAM access key and secret access key
- existing EC2 instance in AWS
- SSH key available locally for Ansible access

## 🔐 AWS CLI Authentication

AWS CLI was configured or reconfigured locally using access keys:

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
| `terraform/main.tf` | EC2 config, security group config, public IP output, and generated inventory |
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

Write the Terraform resource block before importing. Terraform needs the resource name in code before it can connect it to the existing AWS instance.

Import command used:

```bash
terraform import aws_instance.demo <instance-id>
```

After import, the config was adjusted to match the real EC2 state:

- AMI
- instance type
- tags
- security group attachment

Then the plan was checked:

```bash
terraform state list
terraform plan
```

The important part of this phase was reaching a plan that did not destroy or recreate the EC2 instance. The target result was `No changes` or only safe in-place updates.

## 🔐 Security Group Control

After the EC2 instance was imported, a custom security group was defined and attached through Terraform.

Only the required public access was kept open:

- SSH: `22`
- HTTP: `80`
- HTTPS: `443`

Node Exporter stays local to the instance because Prometheus scrapes `localhost:9100` on the same host. Public `9100` ingress is not required for the current single-instance setup, so it was closed.

ICMP was also left closed because it is not required for the current workflow.

This moved access control into Terraform and reduced unnecessary public exposure.

## 🧱 Variables And tfvars

After the imported state matched the real infrastructure, hardcoded values were moved into variables:

```hcl
variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}
```

Values are stored in `terraform.tfvars`:

```hcl
ami           = "ami-0a716d3f3b16d290c"
instance_type = "t3.micro"
```

## 🔗 Generating Ansible Inventory

Terraform exports the EC2 public IP:

```hcl
output "instance_ip" {
  value = aws_instance.demo.public_ip
}
```

That output can be used directly from the command line:

```bash
terraform output -raw instance_ip
```

For quick Ansible checks, the Terraform output can be passed directly into Ansible:

```bash
ansible all -i "$(terraform -chdir=terraform output -raw instance_ip)," \
  -u ubuntu \
  --private-key ~/.ssh/your-key.pem \
  -m ping
```

For playbook runs, this repo also uses Terraform to generate a grouped inventory file.

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

Preview changes:

```bash
terraform plan
```

Apply only after confirming Terraform is not planning to destroy or replace the existing instance:

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
4. Terraform imported the existing EC2 instance
5. Terraform output bridged the infrastructure into Ansible

This single-instance, public-IP setup was later redesigned for zero public exposure — see [05 — Manual Network Re-Architecture](./5-manual-network-rearchitecture.md) and [06 — Terraform Modular Refactor](./6-terraform-modular.md).

---

## 🧭 Next Step

The public-facing single instance managed here was the last phase built on a default VPC. The next phase re-architects the network to remove that public exposure entirely.

>📚 This file is part of the documentation series under /docs/
Next: [05 — Manual Network Re-Architecture](./5-manual-network-rearchitecture.md) →