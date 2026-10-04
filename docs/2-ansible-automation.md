# ⚙️ 02 — Ansible Automation Setup

This phase automates the **Nginx deployment** process across multiple EC2 instances using **Ansible**.

---

## 🧩 Overview
Building upon [1 — Nginx Setup](./1-nginx-setup.md), this stage eliminates manual configuration steps and introduces **Infrastructure as Code (IaC)** principles using Ansible.

It:
- Installs Nginx on **Debian** and **Red Hat** EC2 instances
- Starts and enables the Nginx service
- Deploys a custom HTML page automatically
- Uses a unified playbook to handle multiple OS families

---

## ⚙️ Core Components
| File | Purpose |
|------|----------|
| `inventory.ini` | Defines target EC2 instances (Debian + Red Hat) |
| `playbook.yml` | Contains automation logic |
| `index.html` | Custom web content deployed by playbook |

📁 Full directory: [ansible-project/](/ansible-project)

---

## 🧠 Highlights
- Consistent deployment on multi-OS environments  
- Reusable automation for future updates  
- Foundation for integrating Prometheus & Grafana  

---

## 📸 Sample Output

- ✅ Playbook execution (Ansible run)
- 🌐 Webpages live on both EC2 instances
- 📦 Screenshots: [View in repository](../ansible-project/screenshots/)

---

## 🔗 Next Step
Continue to [3 — Monitoring Setup (Prometheus + Grafana)](./3-monitoring-setup.md)

> 📚 For detailed configuration, refer to [ansible-project/README.md](../ansible-project/README.md)