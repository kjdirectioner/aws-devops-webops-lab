# 🧱 06 — Terraform Modular Refactor (Codifying the Zero-Exposure Network)

This document explains how the manually-built network from Phase 05 was rebuilt as reusable Terraform modules: a custom VPC, public/private subnets, an Application Load Balancer, and access via an EC2 Instance Connect Endpoint — all now defined in code instead of AWS Console clicks. It also covers how Ansible was wired to reach the resulting private-subnet instance, and how Terraform state itself is now managed remotely.

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

It also moves Terraform's own state file off the local disk and into a remote, locked backend, so state isn't tied to one machine and concurrent applies can't corrupt it.

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
| `terraform-modular/providers.tf` | AWS provider config **and** the S3 + DynamoDB remote state backend |
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
  -> move state off local disk into a locked S3 backend
```

## 🔒 Remote State (S3 + DynamoDB Locking)

`terraform-modular/` no longer keeps `terraform.tfstate` on the local machine. `providers.tf` defines an S3 backend with DynamoDB-based locking:

```hcl
terraform {
  backend "s3" {
    bucket         = "tf-state-aws-devops-lab"
    key            = "global/s3/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
```

This means:

- state lives in S3 (encrypted at rest), not in a file that only exists on one laptop
- DynamoDB provides locking, so two people (or two CI runs) can't `apply` against the same state at the same time
- state survives a wiped local machine — anyone with the right AWS credentials and this repo can `terraform init` and pick up exactly where the last apply left off

### Bootstrap: the bucket and table are created manually, not by this Terraform

Terraform's S3 backend has a chicken-and-egg problem: it can't create the very bucket and table it needs in order to store its own state. So the `tf-state-aws-devops-lab` S3 bucket and `terraform-state-locks` DynamoDB table were created **manually** (AWS Console / one-off AWS CLI commands) *before* `providers.tf` referenced them — they are not managed by any `.tf` file in this repo.

Requirements for that manual setup to work correctly:

- **S3 bucket** — versioning enabled is recommended (lets you recover a previous state file if something goes wrong), and it should block public access.
- **DynamoDB table** — must have a partition key named exactly **`LockID`** (type `String`). This is the single most common misconfiguration when wiring up this pattern: without a `LockID` key, `terraform plan`/`apply` will fail to acquire a lock even though the table exists.

### IAM permissions

Whichever AWS identity runs `terraform init` / `plan` / `apply` needs, in addition to the EC2/VPC/ALB permissions implied by the resources themselves:

- `s3:GetObject`, `s3:PutObject`, `s3:ListBucket` on the `tf-state-aws-devops-lab` bucket
- `dynamodb:GetItem`, `dynamodb:PutItem`, `dynamodb:DeleteItem` on the `terraform-state-locks` table

### Notes on the backend block itself

- Backend configuration blocks can't reference input variables (`var.aws_region`, etc.) — Terraform reads the backend config before variables are evaluated. That's why the bucket name, table name, and region in `providers.tf` are hardcoded literals rather than pulled from `variables.tf` — this is expected, not an oversight.
- If a local `terraform-modular/terraform.tfstate` existed before this backend was added, `terraform init` would have prompted to migrate that state into S3. Any future contributor running `terraform init` for the first time after cloning will just download the existing remote state — no migration prompt should appear at that point.

### What's still local state

The legacy `terraform/` folder (Phase 04, import-based, public-IP layout) intentionally still uses **local** state — it's kept as a simple, self-contained reference and isn't part of the current infrastructure, so it wasn't migrated.

## ▶️ Run Terraform

```bash
cd terraform-modular
terraform init
terraform plan
terraform apply
```

`terraform init` will connect to the S3 backend and download the current remote state — no extra flags needed as long as your AWS credentials have the permissions listed above.

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

To confirm locking is working, run `terraform plan` from two terminals at once — the second should block or fail with a "state locked" message referencing the DynamoDB table until the first finishes.

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
- Remote Terraform state (S3 + DynamoDB locking) is now configured for `terraform-modular/` — see the "Remote State" section above. `terraform/` (Phase 04) intentionally remains on local state, since it's a legacy reference and not the active infrastructure.
- The S3 bucket and DynamoDB table backing remote state were provisioned manually, outside of Terraform — see "Bootstrap" above for why.
- CI checks (`terraform validate`, `ansible-lint`, syntax checks) are not yet automated — see the main README's "Next Improvements."

## 🎯 Expected Outcome

- Infrastructure is organized into reusable `vpc` / `security_groups` / `compute` modules
- The web server is no longer directly exposed to the internet
- Traffic reaches the instance only through the ALB
- Administrative access goes through EICE instead of an open SSH ingress rule
- Ansible reaches the private-subnet instance automatically through that same EICE path
- Terraform state for the current infrastructure lives remotely in S3 with DynamoDB locking, instead of on one local machine
- The Phase 05 network design is now reproducible from code, not AWS Console memory

---

## 🧭 Next Step

With the network layer codified, state managed remotely, and Ansible wired through EICE, the next planned improvements are Docker for the app layer and CI/CD for automated `terraform plan`/`apply` and playbook checks on change.

>📚 This file is part of the documentation series under /docs/
Back to project overview: [Main README](../README.md)