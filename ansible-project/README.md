# 🔧 Ansible Automation — Nginx + Monitoring

This folder shows the automation phase of the project: turning a manually configured Ubuntu EC2 web server into a repeatable Ansible workflow.

---

## 🧩 What This Automates

- Installs and starts **Nginx** on Ubuntu
- Deploys a custom `index.html` page
- Installs **Node Exporter** for host metrics
- Deploys **Prometheus** and **Grafana** for monitoring
- Supports both manual and Terraform-generated inventory

---

## 🗂️ Key Files

| File | Purpose |
|------|---------|
| `playbook.yml` | Deploys Nginx to the `web_servers` group |
| `monitoring.yml` | Deploys Node Exporter, Prometheus, and Grafana |
| `inventory.example.ini` | Safe inventory template for manual runs |
| `inventory.generated.ini` | Terraform-generated inventory, ignored by git |
| `roles/` | Ubuntu-focused Ansible roles |

---

## 🔁 How It Fits The Project

This phase comes after the manual EC2 setup.

```text
Manual EC2 setup
  -> Ansible automation
  -> Monitoring
  -> Terraform import + generated inventory
```

The goal is to show that the server can be rebuilt or updated consistently instead of configured by hand every time.

---

## ⚙️ Run Commands

Manual inventory:

```bash
ansible-playbook -i inventory.ini playbook.yml
ansible-playbook -i inventory.ini monitoring.yml
```

Terraform-generated inventory:

```bash
ansible-playbook -i inventory.generated.ini playbook.yml
ansible-playbook -i inventory.generated.ini monitoring.yml
```

---

## 📸 Proof

- [Playbook run screenshot](screenshots/Playbook_run.png)

---

## 📖 Detailed Setup

- [Ansible setup doc](../docs/2-ansible-automation.md)
- [Monitoring setup doc](../docs/3-monitoring-setup.md)
