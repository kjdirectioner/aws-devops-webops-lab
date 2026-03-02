# ☁️ AWS EC2 — Nginx Automation & Monitoring Project

![AWS](https://img.shields.io/badge/AWS-EC2-orange?logo=amazonaws)
![Ansible](https://img.shields.io/badge/Automation-Ansible-red?logo=ansible)
![Grafana](https://img.shields.io/badge/Monitoring-Grafana-blue?logo=grafana)
![Prometheus](https://img.shields.io/badge/Metrics-Prometheus-orange?logo=prometheus)

A hands-on DevOps portfolio project showing progression from **manual deployment** to **automation** and then **observability** on AWS.

---

## What this project demonstrates

- Manual EC2 + Nginx setup fundamentals
- Multi-OS Ansible automation (Debian + Red Hat)
- Monitoring stack with Node Exporter, Prometheus, and Grafana
- Documentation + screenshots for reproducible proof

---

## Project phases

### Phase 1 — Manual Nginx hosting
- Launch EC2, connect over SSH, install Nginx, deploy custom page
- Guide: `docs/1-nginx-setup.md`

### Phase 2 — Ansible automation
- One playbook deploys Nginx across Debian + Red Hat targets
- Guide: `docs/2-ansible-automation.md`
- Project folder: `ansible-project/`

### Phase 3 — Monitoring
- Node Exporter on hosts + Prometheus scrape + Grafana dashboards
- Guide: `docs/3-monitoring-setup.md`
- Monitoring docs/config: `monitoring/README.md`, `monitoring/prometheus.yml`

---

## Architecture (high-level)

```text
Debian EC2
  - Nginx
  - Node Exporter
  - Prometheus
  - Grafana

Red Hat EC2
  - Nginx
  - Node Exporter
```

Prometheus scrapes metrics from both nodes and Grafana visualizes service and host health.

---

## Repository structure

```text
ec2-nginx-web-hosting/
├── ansible-project/       # automation playbooks + roles + screenshots
├── docs/                  # phase-wise setup guides
├── monitoring/            # monitoring configs and notes
├── screenshots/           # manual deployment proof
└── README.md
```

---

## Quick run (automation)

```bash
cd ansible-project
cp inventory.example.ini inventory.ini
# edit inventory.ini with your own host IPs and key paths
ansible-playbook -i inventory.ini playbook.yml
ansible-playbook -i inventory.ini monitoring.yml
```

> `inventory.example.ini` is safe template data. Keep your real inventory local.

---

## Proof artifacts

- Manual setup evidence: `screenshots/`
- Ansible execution + service screenshots: `ansible-project/screenshots/`
- Monitoring proof (targets/dashboard): documented in `docs/3-monitoring-setup.md`

---

## Outcomes

- ✅ Nginx deployed on AWS EC2 (Debian + Red Hat)
- ✅ Repeatable Ansible-based deployment flow
- ✅ Monitoring stack with Prometheus + Grafana
- ✅ Portfolio-ready documentation with implementation proof

---

## Next upgrades

- Terraform for provisioning EC2/VPC/Security Groups
- Dockerized monitoring stack
- CI/CD with GitHub Actions
