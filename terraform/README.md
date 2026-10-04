# 🏗️ Terraform — Import Existing AWS Infrastructure

This folder shows the Infrastructure as Code phase of the project. The EC2 instance already existed in AWS, so Terraform was added using an import workflow instead of recreating the infrastructure.

---

## 🧩 What This Shows

- AWS provider configuration
- Importing existing EC2 and security group resources
- Managing infrastructure state with Terraform
- Generating Ansible inventory from Terraform output

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
  -> AWS CLI authentication
  -> Terraform import
  -> Terraform state
  -> generated Ansible inventory
  -> Ansible deployment and monitoring
```

Terraform generates:

```text
ansible-project/inventory.generated.ini
```

That file is ignored by git because it contains local infrastructure output.

---

## 📖 Detailed Setup

- [Terraform setup doc](../docs/4-terraform-setup.md)
