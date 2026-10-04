# Ansible Automation: Nginx Deployment on AWS EC2

## 🧩 Overview
This project automates the deployment and configuration of an **Nginx web server** on AWS EC2 instances using **Ansible**.  
It demonstrates **multi-environment automation**, handling both **Debian-based** and **Red Hat-based** systems in a single playbook.

---

## ⚙️ Tech Stack
- **AWS EC2** — Cloud instance host (Ubuntu / Red Hat)  
- **Ansible** — Automation and configuration management  
- **Nginx** — Web server  
- **Git & GitHub** — Version control and project documentation  

---

## 📁 Project Structure

```bash

nginx-aws-project/
│
├── ansible-project/
│   ├── inventory.ini      # Target EC2 instance(s)     
│   ├── playbook.yml       # config for ansible    
│   ├── index.html         # Custom webpage deployment
│   ├── screenshots/       # Deployment proof
│   └── README.md          # Documentation
```

---

## 🧠 How It Works

### Step 1: Inventory
Defines all target hosts with connection details using **Elastic IPs** for consistent access.
```ini
[web-servers]
# Debian-based EC2
56.228.52.229 ansible_user=ubuntu ansible_ssh_private_key_file=~/downloads/MY_Key.pem
# Red Hat-based EC2
54.153.142.128 ansible_user=ec2-user ansible_ssh_private_key_file=~/downloads/Red_Key.pem

> Note: Elastic IPs ensure static public addresses for both instances.
```
---
### Step 2: Playbook Execution

The playbook automates:
- Installing Nginx on both Debian and Red Hat systems
- Starting and enabling the Nginx service	
- Copying a custom index.html to the correct web directory
- Full Ansible playbook: [playbook.yml](playbook.yml)

---

### Multi-Environment Support

- Detects Debian vs Red Hat and applies OS-specific tasks.
- Handles service start, enabling, and file placement automatically.
  
---

### Find the web page here 

Deployment confirmation and web server status:
- [ Debian EC2 ](http://56.228.52.229)
- [ Red Hat EC2 ](http://54.153.142.128)

---

### Screenshots

- Debian EC2 Webpage: ![Debian](screenshots/Debian_servicepage.png)
- Red Hat EC2 Webpage: ![Red Hat](screenshots/Redhat_servicepage.png)
- Playbook Run: ![Playbook Execution](screenshots/Playbook_run.png)
- Debian EC2 Web-server: ![Debian-server](screenshots/Debian_server.png)
- Red Hat EC2 Web-server: ![Red Hat-server](screenshots/Redhat_server.png)

---

### 🚀 Next Steps
1. Integrate **Prometheus + Grafana** for EC2 monitoring.  
2. Configure **VPC Peering** between multiple EC2 instances/accounts.  
3. Use **AWS EC2 Instance Scheduler** for automated start/stop.  
4. Future enhancements: **CI/CD pipelines**, **Docker containerization**, **Terraform**, and **AI-assisted monitoring agents**.  

> Goal: Learn while building, document the process, and showcase hands-on DevOps and cloud skills.


