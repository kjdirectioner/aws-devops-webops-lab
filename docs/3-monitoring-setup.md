# 📊 03 — Monitoring Setup

This document explains the current monitoring workflow used in the project on a single Ubuntu EC2 instance.

---

## 🧭 Documentation Path

```text
01 Manual EC2 + Nginx setup
   -> 02 Ansible automation
   -> 03 Monitoring setup  ← you are here
   -> 04 Terraform import setup
   -> 05 Manual network re-architecture
   -> 06 Terraform modular refactor
```

This phase adds visibility after the web server and automation workflow are working.

Previous: [02 — Ansible Automation Setup](./2-ansible-automation.md)

Next: [04 — Terraform Import Setup](./4-terraform-setup.md)

---

## 🧩 Overview

The monitoring setup adds visibility into the host after deployment.

It uses:

- Node Exporter for host metrics
- Prometheus for metric collection
- Grafana for dashboards

## 🏗️ Architecture

```text
Ubuntu EC2
  - Node Exporter (9100)
  - Prometheus (9090)
  - Grafana (3000)
```

Prometheus scrapes the local Node Exporter endpoint at `localhost:9100`.

## ⚙️ How Monitoring Is Deployed

Monitoring is deployed through Ansible, not by following manual install steps line by line.

The playbook is:

- [ansible-project/monitoring.yml](../ansible-project/monitoring.yml)

It applies:

- `node_exporter` to `web_servers`
- `prometheus` to `monitoring`
- `grafana` to `monitoring`

In the current workflow, both groups point to the same Ubuntu host.

## 🗂️ Inventory Requirement

The inventory needs both groups:

```ini
[web_servers]
<ubuntu_host_or_ip> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/<ubuntu_key>.pem

[monitoring]
<ubuntu_host_or_ip> ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/<ubuntu_key>.pem
```

Use either:

- `ansible-project/inventory.ini` for manual runs
- `ansible-project/inventory.generated.ini` for Terraform-assisted runs

## 🚀 Run The Monitoring Playbook

### Manual inventory

```bash
ansible-playbook -i ansible-project/inventory.ini ansible-project/monitoring.yml
```

### Terraform-generated inventory

```bash
ansible-playbook -i ansible-project/inventory.generated.ini ansible-project/monitoring.yml
```

## 🛠️ Config Used

The Prometheus scrape config tracked in this repo is:

- [monitoring/prometheus.yml](../monitoring/prometheus.yml)

Current exporter target:

```yaml
- job_name: "node_exporter"
  scrape_interval: 10s
  static_configs:
    - targets: ["localhost:9100"]
```

## ✅ Validation Steps

After deployment, validate the services:

```bash
systemctl status node_exporter
systemctl status prometheus
systemctl status grafana-server
```

Check the local endpoints:

```bash
curl http://localhost:9100/metrics
curl http://localhost:9090/-/healthy
```

Access Grafana through an SSH tunnel:

```bash
ssh -L 3000:localhost:3000 ubuntu@<ubuntu-public-ip>
```

Then open:

```text
http://localhost:3000
```

## 🎯 Expected Outcome

- Node Exporter is reachable locally on port `9100`
- Prometheus shows the exporter target as `UP`
- Grafana loads dashboards successfully
- The project has operational visibility beyond deployment

## 📸 Proof

Screenshots are available in:

- [monitoring/grafana/screenshots](../monitoring/grafana/screenshots)

These show:

- Grafana dashboards
- instance selector
- Prometheus targets page

---

## 🧭 Next Step

After monitoring is in place, the next phase brings the existing AWS infrastructure under Terraform using an import workflow.

>📚 This file is part of the documentation series under /docs/
Next: [04 — Terraform Import Setup](./4-terraform-setup.md) →