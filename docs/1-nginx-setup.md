# ☁️ 01 — EC2 + Nginx Web Hosting

This document explains the **manual deployment of a simple Nginx web server** on an AWS EC2 instance.  
It serves as **Phase 1** of the larger Nginx AWS automation and monitoring project.

---

## 🧭 Documentation Path

You are here:

```text
01 Manual EC2 + Nginx setup  ← you are here
   -> 02 Ansible automation
   -> 03 Monitoring setup
   -> 04 Terraform import setup
   -> 05 Manual network re-architecture
   -> 06 Terraform modular refactor
```

This first phase establishes the baseline server before automation, monitoring, and Terraform are added.

Next: [02 — Ansible Automation Setup](./2-ansible-automation.md)

---

## 🧩 Overview

This project demonstrates how to:
- Launch an EC2 instance on AWS  
- Configure it via SSH  
- Install and start Nginx  
- Host a basic custom HTML webpage  

---

## 🧱 Project Structure Overview

This project is divided into several progressive phases, each representing a step in automating and managing web hosting on AWS EC2:
```
aws-devops-webops-lab/
│
├── docs/
│   ├── 1-nginx-setup.md                   # Manual Nginx setup on AWS EC2 (this file)
│   ├── 2-ansible-automation.md            # Automating Ubuntu Nginx setup with Ansible
│   ├── 3-monitoring-setup.md              # Monitoring setup with Prometheus + Grafana
│   ├── 4-terraform-setup.md               # Import existing AWS infrastructure into Terraform
│   ├── 5-manual-network-rearchitecture.md # Manual zero-exposure network redesign
│   └── 6-terraform-modular.md             # Codifying the network as Terraform modules

```        
---

## ⚙️ Skills & Tools Used
- **AWS EC2 (Free Tier)**  
- **Ubuntu AMI**  
- **Security Groups** (Ports 22 & 80)  
- **Nginx Web Server**  
- **HTML** for static site hosting  
- **SSH (Terminal / iTerm2)**  

---

## 🚀 Step-by-Step Setup

### 1️⃣ Launch EC2 Instance
- Choose **Ubuntu AMI** (Amazon Machine Image)
- Select **t3.micro** instance (Free Tier eligible)
- Create a **new key pair** and download it
- In **Network Settings**, create a new Security Group:
  - Allow **SSH (Port 22)** for remote login  
  - Allow **HTTP (Port 80)** for web access  
- Keep default 8 GB storage (gp3 volume)
- Launch the instance

---

### 2️⃣ Connect via SSH
Use your key to connect securely:
```bash
ssh -i ~/.ssh/<your-key>.pem ubuntu@<your-public-ip>
```

### 3. Update, Install & Start Nginx
Run the following commands to install, start, and enable Nginx:
```bash
sudo apt update 
sudo apt install nginx  
sudo systemctl start nginx 
sudo systemctl enable nginx  
```
---  
### 4.Host HTML Page
Navigate to default directory and edit the index file:
``` bash 
/var/www/html$ 
sudo nano index.html  
```
### 5. Replace the Nginx page with custom script
Paste the following into the index.html
``` html 
<!DOCTYPE html>
<html>
<body>
  <h1>Successfully Deployed on AWS EC2!</h1> 
  <p>Deployed on AWS EC2 with Nginx by Krishna</p>
  <p>Next: Automating with Ansible</p>
</body>
</html> 
```
### Result
After saving and reloading in the browser, the custom page was live on the public IP.
![Custom Web Page Running](../screenshots/Custom-webpage.png)
## Additional Screenshots
Here are some extra screenshots showing the setup process and server status:

- **EC2 Instance Running:**  
  ![EC2 Running](../screenshots/ec2-running.png)

- **SSH Connection to EC2:**  
  ![SSH Connection](../screenshots/ssh-connection.png)

- **Installing Nginx:**  
  ![Installing Nginx](../screenshots/installing-nginx.png)

- **Nginx Service Status:**  
  ![Nginx Status](../screenshots/nginx-status.png)

## 🔁 Related Phases

- [02 — Ansible Automation Setup](./2-ansible-automation.md): automate EC2 + Nginx deployment
- [03 — Monitoring Setup](./3-monitoring-setup.md): monitor the Ubuntu EC2 instance
- [04 — Terraform Import Setup](./4-terraform-setup.md): bring existing AWS infrastructure under IaC
- [05 — Manual Network Re-Architecture](./5-manual-network-rearchitecture.md): redesign the network for zero public exposure
- [06 — Terraform Modular Refactor](./6-terraform-modular.md): codify the network redesign as Terraform modules

---

### 🧭 Notes & Next Steps

This phase (manual setup) lays the foundation for:

- Automating server configuration via Ansible
- Extending the single-instance setup with repeatable automation
- Adding Prometheus + Grafana monitoring

>📚 This file is part of the documentation series under /docs/
Next: [02 — Ansible Automation Setup](./2-ansible-automation.md) →