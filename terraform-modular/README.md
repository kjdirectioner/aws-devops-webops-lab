# 🧱 Terraform Modular — VPC, ALB & Private Compute

This folder shows the code-first phase of the network re-architecture. [Phase 05](../docs/5-manual-network-rearchitecture.md) proved the design by hand in the AWS Console: a custom VPC, private compute, an Application Load Balancer, and access via an EC2 Instance Connect Endpoint instead of an open SSH rule. This folder codifies that exact design as reusable Terraform modules, and wires Ansible to reach the resulting private-subnet instance through that same EICE path.

---

## 🧩 What This Adds

- A custom **VPC** with public and private subnets across 2 availability zones
- A **NAT gateway** so the private subnet can still reach the internet for updates
- An **Application Load Balancer** as the only public entry point for web traffic
- A **chained security group** design (`alb_sg` -> `app_sg` <- `eice_sg`) instead of one open group
- An **EC2 Instance Connect Endpoint** for admin access, replacing a bastion host and a public IP on the instance
- A generated Ansible inventory (`ansible-project/inventory.ini`) keyed on **instance ID**, so Ansible can reach the instance automatically through EICE

---

## 🏗️ Module Layout

```text
terraform-modular/
├── modules/
│   ├── vpc              # VPC, subnets, IGW, NAT gateway, route tables
│   ├── security_groups   # alb_sg, app_sg, eice_sg
│   └── compute           # EC2 instance, ALB, target group, listener, EICE
├── main.tf                # wires the modules together + generates Ansible inventory
├── variables.tf
├── terraform.tfvars
├── providers.tf
└── outputs.tf
```

---

## 🔁 Why This Was Added

The earlier `terraform/` folder proved that existing AWS infrastructure could be imported and managed as code. It intentionally kept things simple: one instance, one security group, one public IP.

That single-instance layout was then manually redesigned in Phase 05 for zero public exposure on the compute tier. This module set is the Terraform version of that redesign — the same architecture, but reproducible from code instead of AWS Console clicks.

---

## 🗂️ Key Files

| File | Purpose |
|------|---------|
| `main.tf` | Wires `vpc`, `security_groups`, and `compute` modules together, and generates `ansible-project/inventory.ini` |
| `variables.tf` | Region, VPC CIDR, AMI, instance type |
| `terraform.tfvars` | Local non-secret variable values |
| `outputs.tf` | Instance private IP and ALB DNS name |
| `modules/vpc` | Custom VPC, public/private subnets, IGW, NAT gateway |
| `modules/security_groups` | `alb_sg`, `app_sg`, `eice_sg` |
| `modules/compute` | EC2 instance, ALB, target group, listener, EICE |

---

## ⚙️ Run Commands

```bash
cd terraform-modular
terraform init
terraform plan
terraform apply
```

Read the outputs:

```bash
terraform output load_balancer_url
terraform output app_server_private_ip
```

Run Ansible against the resulting instance:

```bash
cd ../ansible-project
ansible-playbook -i inventory.ini playbook.yml
ansible-playbook -i inventory.ini monitoring.yml
```

---

## 🔗 How Ansible Reaches This Instance

The web server sits in a **private subnet with no public IP** — it's only reachable through the ALB (port `80`) for web traffic, or through the EICE endpoint (port `22`) for administrative access.

Since there's no IP to put in an inventory file, `main.tf`'s `local_file` resource generates `ansible-project/inventory.ini` using the **instance ID** as `ansible_host` instead:

```ini
[web_servers]
web-server-1 ansible_host=<instance-id>

[monitoring]
monitor-1 ansible_host=<instance-id>
```

`ansible-project/ansible.cfg` then defines an SSH `ProxyCommand` that calls `aws ec2-instance-connect send-ssh-public-key` and `open-tunnel` using that instance ID (`%n`) to open a temporary tunnel on every connection — EICE operates on instance ID, not IP, so this is the correct mechanism for a target with no address of its own. No manual tunnel setup or bastion host is required.

---

## 🧭 Notes

- The original `terraform/` folder is kept as-is as the import-based reference; this folder is the current version of the infrastructure.
- Remote Terraform state (S3 + DynamoDB locking) is not yet configured; both this folder and `terraform/` currently use local state.
- CI checks (`terraform validate`, `ansible-lint`) are planned but not yet automated.

---

## 📖 Detailed Setup

- [Manual network re-architecture doc](../docs/5-manual-network-rearchitecture.md)
- [Terraform modular refactor doc](../docs/6-terraform-modular.md)