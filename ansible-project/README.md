# 🔧 Ansible Automation — Nginx + Monitoring

This folder shows the automation phase of the project: turning a manually configured Ubuntu EC2 web server into a repeatable Ansible workflow.

---

## 🧩 What This Automates

- Installs and starts **Nginx** on Ubuntu
- Deploys a custom `index.html` page
- Installs **Node Exporter** for host metrics
- Deploys **Prometheus** and **Grafana** for monitoring
- Supports both manual and Terraform-generated inventory, including the private-subnet layout

---

## 🗂️ Key Files

| File | Purpose |
|------|---------|
| `playbook.yml` | Deploys Nginx to the `web_servers` group |
| `monitoring.yml` | Deploys Node Exporter, Prometheus, and Grafana |
| `inventory.example.ini` | Safe inventory template for manual runs |
| `inventory.generated.ini` / `inventory.ini` | Terraform-generated inventory, ignored by git |
| `roles/` | Ubuntu-focused Ansible roles |
| `ansible.cfg` | SSH config, including the EICE `ProxyCommand` used for the private-subnet layout |

---

## 🔁 How It Fits The Project

This phase comes after the manual EC2 setup.

```text
Manual EC2 setup
  -> Ansible automation
  -> Monitoring
  -> Terraform import + generated inventory
  -> Manual network re-architecture (private subnet, ALB, EICE)
  -> Terraform modular refactor + EICE-based Ansible wiring
```

The goal is to show that the server can be rebuilt or updated consistently instead of configured by hand every time.

> **Current status:** the instance now runs in a private subnet behind an ALB, with no public IP (see [`terraform-modular/`](../terraform-modular/README.md)). Ansible reaches it through an EC2 Instance Connect Endpoint (EICE): the Terraform-generated inventory uses the **instance ID** as `ansible_host` (there is no IP to target), and `ansible.cfg`'s `ProxyCommand` opens an EICE tunnel keyed off that instance ID automatically on every connection. The older `inventory.example.ini` / public-IP workflow below still works unchanged for the legacy `terraform/` (Phase 4) layout.

---

## ⚙️ Run Commands

Manual inventory (legacy public-IP layout):

```bash
ansible-playbook -i inventory.ini playbook.yml
ansible-playbook -i inventory.ini monitoring.yml
```

Terraform-generated inventory (legacy public-IP layout, from `terraform/`):

```bash
ansible-playbook -i inventory.generated.ini playbook.yml
ansible-playbook -i inventory.generated.ini monitoring.yml
```

Terraform-generated inventory (current private-subnet layout, from `terraform-modular/`, via EICE):

```bash
ansible-playbook -i inventory.ini playbook.yml
ansible-playbook -i inventory.ini monitoring.yml
```

`ansible.cfg`'s `ProxyCommand` handles sending the temporary SSH public key and opening the EICE tunnel per host — no manual tunnel setup needed before running the playbook.

---

## 📸 Proof

The automation step was validated with a successful playbook run:

This proof image was captured during the earlier two-instance phase, so two host IPs appear in the output. The current repo has since been refactored to a single Ubuntu instance.

![Playbook run screenshot](screenshots/Playbook_run.png)

---

## 📖 Detailed Setup

- [Ansible setup doc](../docs/2-ansible-automation.md)
- [Monitoring setup doc](../docs/3-monitoring-setup.md)
- [Terraform modular refactor doc](../docs/6-terraform-modular.md)