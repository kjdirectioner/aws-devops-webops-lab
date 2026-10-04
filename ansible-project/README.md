# 🔧 Ansible Automation — Nginx + Monitoring Stack

This folder contains automation for:
1. **Nginx deployment** on Debian + Red Hat EC2 instances
2. **Monitoring stack deployment** using Node Exporter, Prometheus, and Grafana

---

## What’s automated

### 1) Nginx deployment (`playbook.yml`)
- Installs Nginx on Debian and Red Hat families
- Copies custom `index.html`
- Ensures Nginx is enabled and running

### 2) Monitoring stack (`monitoring.yml`)
- `node_exporter` role: host metrics on target nodes
- `prometheus` role: scrape and store metrics
- `grafana` role: visualize metrics

---

## Project structure

```text
ansible-project/
├── inventory.ini
├── playbook.yml
├── monitoring.yml
├── roles/
│   ├── node_exporter/
│   ├── prometheus/
│   └── grafana/
├── index.html
└── screenshots/
```

---

## Prerequisites

- Ansible (`ansible-core`) installed on control machine
- SSH reachability to both EC2 hosts
- Key-based auth configured
- Security groups allow:
  - `22` (SSH)
  - `9100` (Node Exporter)
  - `9090` (Prometheus)
  - `3000` (Grafana access via tunnel/preferred restricted access)

---

## Inventory

`inventory.ini` is currently maintained with active host values for live deployment.

Example shape:

```ini
[web-servers]
<debian_host_or_ip> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/<debian_key>.pem
<rhel_host_or_ip>   ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/<redhat_key>.pem
```

---

## Run commands

### Deploy Nginx
```bash
ansible-playbook -i inventory.ini playbook.yml
```

### Deploy monitoring stack
```bash
ansible-playbook -i inventory.ini monitoring.yml
```

---

## Validation checklist

After execution:

- `ansible all -i inventory.ini -m ping` passes
- Nginx is active on both hosts
- Custom web page is served from both hosts
- Prometheus targets show `UP`
- Grafana dashboards populate host metrics

---

## Technical notes

- Prometheus role include is case-corrected to:
  - `roles/prometheus/tasks/main.yml` → `include_tasks: debian.yml`
- This avoids Linux case-sensitivity issues during task includes.

---

## Proof

See `screenshots/` in this folder for:
- Playbook execution proof
- Debian and Red Hat webpage/service validation

Monitoring proof is documented in:
- `../docs/3-monitoring-setup.md`
- `../monitoring/README.md`
