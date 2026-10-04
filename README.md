# ☁️ AWS EC2 — Nginx Automation & Monitoring Project

![AWS](https://img.shields.io/badge/AWS-EC2-orange?logo=amazonaws)
![Ansible](https://img.shields.io/badge/Automation-Ansible-red?logo=ansible)
![Grafana](https://img.shields.io/badge/Monitoring-Grafana-blue?logo=grafana)
![Prometheus](https://img.shields.io/badge/Metrics-Prometheus-orange?logo=prometheus)
![License](https://img.shields.io/badge/License-MIT-green)

A compact, staged **DevOps portfolio project** showing the evolution from a manual EC2/Nginx deployment to automation and monitoring.

> 💡 This project demonstrates **end-to-end deployment, automation, and observability** — simulating real-world DevOps workflows in a modern cloud environment.

- **Phase 1:** Manual Nginx setup on EC2  
- **Phase 2:** Automation using Ansible (multi-OS)  
- **Phase 3:** Monitoring with Prometheus + Grafana

Each phase is fully documented and reproducible, allowing anyone to follow the process and understand the progression of skills.

---

## 🧩 Architecture

```text
┌──────────────────────────────┐
│         Debian EC2           │
│  ├─ Nginx Server             │
│  ├─ Prometheus (9090)        │
│  ├─ Grafana (3000)           │
│  └─ Node Exporter (9100)     │
└──────────────▲───────────────┘
       │   VPC Peering   │
┌──────────────┴───────────────┐
│          Red Hat EC2         │
│  └─ Node Exporter (9100)     │
└──────────────────────────────┘
```

- **Prometheus** scrapes `node_exporter` on both hosts.  
- **Grafana** visualizes the metrics (accessed securely via SSH tunnel).  
- **VPC peering** enables private cross-VPC metric scraping.

---

## 📂 Repository Structure

```bash
nginx-aws-project/
│
├── ansible-project/                   # Ansible automation
│   ├── inventory.ini                  # EC2 instance details
│   ├── playbook.yml                   # Automates Nginx deployment
│   ├── index.html                     # Custom webpage
│   ├── screenshots/
│   │   ├── Debian_server.png
│   │   ├── Debian_servicepage.png
│   │   ├── Playbook_run.png
│   │   ├── Redhat_server.png
│   │   └── Redhat_servicepage.png
│   └── README.md
│
├── docs/                              # Step-by-step setup guides
│   ├── 1-nginx-setup.md
│   ├── 2-ansible-automation.md
│   └── 3-monitoring-setup.md
│
├── monitoring/                        # Monitoring configs
│   ├── prometheus.yml                 # Prometheus scrape targets
│   ├── grafana/
│   │   └── screenshots/
│   │       ├── grafana-dashboard-overview.png
│   │       ├── grafana-instance-selector.png
│   │       └── prometheus-targets-up.png
│   └── README.md
│
├── screenshots/                       # Initial Nginx setup proof
│   ├── Custom-webpage.png
│   ├── ec2-running.png
│   ├── installing-nginx.png
│   ├── nginx-status.png
│   └── ssh-connection.png
│
└── README.md                          # (this file)
```
---

## 📖 Project Documentation

### Phase 1 — Manual EC2 + Nginx Setup

Launch an EC2 instance, install Nginx manually, and deploy a custom HTML page.
📄 View Guide → ￼[docs/1-nginx-setup.md](/docs/1-nginx-setup.md)￼
🖼️ Screenshots → ￼[screenshots/](/screenshots/)￼

---

### Phase 2 — Ansible Automation

Automates Nginx deployment on both Debian and Red Hat EC2 instances using one playbook.
📄 View Guide → ￼[docs/2-ansible-automation.md](/docs/2-ansible-automation.md)￼
📂 Ansible Project → ￼[Ansible Project](/ansible-project/)￼
🖼️ Automation Proof → ￼[ansible-project/screenshots/](/ansible-project/screenshots/)￼

⸻

### Phase 3 — Monitoring (Prometheus + Grafana)

Implements Node Exporter, Prometheus, and Grafana for cross-VPC real-time monitoring.
📄 Setup Guide → ￼[docs/3-monitoring-setup.md](/docs/3-monitoring-setup.md)￼
📂 Monitoring Files → ￼[monitoring/](/monitoring/) 
🖼️ Dashboard → ￼[monitoring/grafana/screenshots/](/monitoring/grafana/screenshots/)

---
## 🚀 Project Outcomes

- ✅ Deployed Nginx web servers on multi-OS AWS EC2 instances  
- ⚙️ Automated provisioning using Ansible playbooks  
- 📈 Implemented real-time monitoring with Prometheus + Grafana  
- 🔒 Secured access via SSH tunneling & private VPC peering  
- 🧭 Documented all phases with reproducible configuration files
  
---
## 🧰 Tech Stack

| Category | Tools & Technologies |
|-----------|----------------------|
| ☁️ **Cloud Platform** | AWS EC2 |
| 🌐 **Web Server** | Nginx |
| ⚙️ **Automation** | Ansible |
| 📊 **Monitoring & Visualization** | Prometheus · Node Exporter · Grafana |
| 🧱 **Infrastructure as Code (Planned)** | Terraform |
| 🔁 **CI/CD (Planned)** | GitHub Actions |
| 🐳 **Containerization (Planned)** | Docker · Kubernetes (EKS) |
| 💾 **Version Control** | Git · GitHub |

---

## 🪜 Next Steps (Planned Enhancements)

| Goal | Description |
|------|--------------|
| 🧩 **Automate Monitoring Stack** | Use Ansible to deploy Prometheus + Node Exporter + Grafana |
| 🏗️ **Infrastructure as Code** | Implement Terraform for EC2, VPC, and Security Group setup |
| 🐳 **Containerization** | Use Docker Compose for Prometheus–Grafana stack |
| 🔁 **CI/CD Pipeline** | Automate deployments via GitHub Actions |
| ☸️ **Kubernetes (EKS)** | Migrate containerized workloads for scalability |

---

🧭 Each phase of this project is documented and versioned in /docs.
>The goal: Build hands-on, incremental DevOps projects that showcase automation, observability, and infrastructure mastery.

