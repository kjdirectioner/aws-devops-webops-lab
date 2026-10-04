# 🏗️ Terraform — Import Existing AWS Infrastructure

This folder shows the Infrastructure as Code phase of the project. The EC2 instance already existed in AWS, so Terraform was added using an import workflow instead of recreating the infrastructure.

> **Note:** this folder is kept as the import-based, single-instance reference. The network was later redesigned for zero public exposure and rebuilt with a modular Terraform layout — see [`terraform-modular/`](../terraform-modular/README.md) and [docs/6-terraform-modular.md](../docs/6-terraform-modular.md).

---

## 🧩 What This Shows

- AWS provider configuration
- Importing an existing EC2 instance
- Matching Terraform config to the real AWS setup
- Moving AMI and instance type into variables and `terraform.tfvars`
- Creating and attaching a custom security group
- Closing unnecessary public access for local-only monitoring traffic
- Exporting the public IP for Ansible
- Managing infrastructure state with Terraform
- Bridging Terraform output into Ansible

---

## 🔁 Why Terraform Was Added

The project started manually, then moved into automation and monitoring. Terraform was added later to bring the already-running AWS resources under code.

That mirrors a real-world situation: not every cloud environment starts clean. Sometimes the job is to adopt existing infrastructure and make it more repeatable.

---

## 🗂️ Key Files

| File | Purpose |
|------|---------|
| `provider.tf` | AWS provider and region |
| `main.tf` | EC2, security group, output, and generated inventory |
| `terraform.tfvars` | Local non-secret variable values |
| `.terraform.lock.hcl` | Provider lock file |

---

## ⚙️ Workflow

```text
Existing AWS EC2 infrastructure
  -> AWS CLI reconfiguration
  -> terraform import aws_instance.demo <instance-id>
  -> config matched to real AWS state
  -> terraform plan reached no destroy/recreate
  -> variables moved to terraform.tfvars
  -> custom security group attached
  -> unnecessary public ports closed
  -> public IP exported
  -> Terraform output passed into Ansible
```

Terraform generates:

```text
ansible-project/inventory.generated.ini
```

The public IP can also be read directly:

```bash
terraform output -raw instance_ip
```

The generated inventory file is ignored by git because it contains local infrastructure output.

---

## 📖 Detailed Setup

- [Terraform setup doc](../docs/4-terraform-setup.md)
- [What replaced this layout →](../docs/6-terraform-modular.md)