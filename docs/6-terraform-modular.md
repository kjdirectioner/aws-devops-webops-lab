# 🧱 06 — Terraform Modular Refactor (Codifying the Zero-Exposure Network)

This document explains how the manually-built network from Phase 05 was rebuilt as reusable Terraform modules: a custom VPC, public/private subnets, an Application Load Balancer, and access via an EC2 Instance Connect Endpoint — all now defined in code instead of AWS Console clicks. It also covers how Ansible was wired to reach the resulting private-subnet instance.

---

## 🧭 Documentation Path

```text
01 Manual EC2 + Nginx setup
   -> 02 Ansible automation
   -> 03 Monitoring setup
   -> 04 Terraform import setup
   -> 05 Manual network re-architecture
   -> 06 Terraform modular refactor  ← you are here
```

Previous: [05 — Manual Network Re-Architecture](./5-manual-network-rearchitecture.md)

Project overview: [Main README](../README.md)

---

## 🧩 Overview

Phase 05 proved the network design by hand. This phase turns that design into reusable modules so the environment can be destroyed and rebuilt from code:

- `modules/vpc` — custom VPC, public + private subnets, IGW, NAT gateway, route tables
- `modules/security_groups` — a chained set of security groups instead of one open group
- `modules/compute` — the Nginx instance, an Application Load Balancer, and an EC2 Instance Connect Endpoint for access

## 🏗️ Architecture

```text
Internet
  |
  v
Application Load Balancer (public subnets)
  |  :80
  v
Nginx EC2 instance (private subnet, no public IP)

EC2 Instance Connect Endpoint (public subnet)
  -> replaces a bastion host for SSH/admin access into the private subnet
```

This is the same shape proven manually in Phase 05, now expressed entirely as Terraform.

## 🗂️ Key Files

| File | Purpose |
|------|---------|
| `terraform-modular/main.tf` | Wires the three modules together and generates `ansible-project/inventory.ini` |
| `terraform-modular/variables.tf` | Region, VPC CIDR, AMI, instance type |
| `terraform-modular/terraform.tfvars` | Local non-secret variable values |
| `terraform-modular/outputs.tf` | Private IP of the instance, ALB DNS name |
| `terraform-modular/modules/vpc` | Custom VPC, public/private subnets, IGW, NAT gateway |
| `terraform-modular/modules/security_groups` | `alb_sg`, `app_sg`, `eice_sg` |
| `terraform-modular/modules/compute` | EC2 instance, ALB, target group, listener, EICE |

## 🔐 Security Group Chain

Instead of one security group with everything open, access is chained through three groups:

- **`alb_sg`** — accepts `80` from the internet, forwards to the app tier
- **`app_sg`** — accepts `80` only from `alb_sg`, and `22` only from `eice_sg`
- **`eice_sg`** — has no inbound rule; it only egresses `22` toward `app_sg`

```text
Internet -> alb_sg (80) -> app_sg (80)
EICE      -> eice_sg (22 out) -> app_sg (22 in, from eice_sg only)
```

The instance itself never accepts traffic directly from `0.0.0.0/0` on any port.

## 🚀 Module Workflow

```text
Manually-built network (Phase 05)
  -> design VPC with public + private subnets across 2 AZs
  -> add NAT gateway so the private instance can still reach the internet
  -> split one security group into alb_sg / app_sg / eice_sg
  -> move the EC2 instance into a private subnet, drop the public IP
  -> put an ALB in front of it in the public subnets
  -> add an EC2 Instance Connect Endpoint for SSH access instead of a bastion
  -> expose only private_ip and alb_dns as outputs
  -> generate an Ansible inventory keyed on instance ID and wire it through EICE
```

## ▶️ Run Terraform

```bash
cd terraform-modular
terraform init
terraform plan
terraform apply
```

Get the outputs:

```bash
terraform output load_balancer_url
terraform output app_server_private_ip
```

## ✅ Validation Steps

```bash
curl http://$(terraform output -raw load_balancer_url)
```

Expected result: the same custom Nginx page from Phase 01/02, now served through the ALB instead of a direct public IP.

Check target health:

```text
AWS Console -> EC2 -> Target Groups -> web-servers-tg -> Targets
```

The instance should show as `healthy`.

## 🔗 Ansible Wiring Through EICE (Complete)

The private-subnet instance has no public IP and no reachable private IP from the operator's machine, so a normal `ansible_host: <ip>` inventory entry doesn't work here. Instead:

- `terraform-modular/main.tf` generates `ansible-project/inventory.ini` with `ansible_host` set to the **instance ID**, not an IP.
- `ansible-project/ansible.cfg` defines an SSH `ProxyCommand` that runs `aws ec2-instance-connect send-ssh-public-key` and `open-tunnel` against that instance ID before every connection, using `%n` (the inventory hostname) as the instance ID.
- This means EICE tunneling happens automatically and transparently on every `ansible-playbook` run — no manual `aws ec2-instance-connect open-tunnel` step or temporary bastion is needed.

This closes the gap noted in earlier drafts of this doc. Running:

```bash
ansible-playbook -i ansible-project/inventory.ini ansible-project/playbook.yml
ansible-playbook -i ansible-project/inventory.ini ansible-project/monitoring.yml
```

now deploys Nginx and the monitoring stack onto the private-subnet instance end-to-end, entirely through code.

## 🧭 Notes & Remaining Gaps

- The original Phase 04 `terraform/` folder is left in place as the import-based, single-instance reference; `terraform-modular/` is the current version of the infrastructure.
- Remote Terraform state (e.g. S3 + DynamoDB locking) is not yet configured for either `terraform/` or `terraform-modular/`; both currently use local state.
- CI checks (`terraform validate`, `ansible-lint`, syntax checks) are not yet automated — see the main README's "Next Improvements."

## 🎯 Expected Outcome

- Infrastructure is organized into reusable `vpc` / `security_groups` / `compute` modules
- The web server is no longer directly exposed to the internet
- Traffic reaches the instance only through the ALB
- Administrative access goes through EICE instead of an open SSH ingress rule
- Ansible reaches the private-subnet instance automatically through that same EICE path
- The Phase 05 network design is now reproducible from code, not AWS Console memory

---

## 🧭 Next Step

With the network layer codified and Ansible wired through EICE, the next planned improvements are Docker for the app layer, remote Terraform state, and CI/CD for automated `terraform plan`/`apply` and playbook checks on change.

>📚 This file is part of the documentation series under /docs/
Back to project overview: [Main README](../README.md)