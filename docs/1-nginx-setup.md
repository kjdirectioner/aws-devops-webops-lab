# ☁️ 01 — EC2 + Nginx Web Hosting

This document explains the **manual deployment of a simple Nginx web server** on an AWS EC2 instance.  
It serves as **Phase 1** of the larger Nginx AWS automation and monitoring project.

---

## 🧩 Overview

This project demonstrates how to:
- Launch an EC2 instance on AWS  
- Configure it via SSH  
- Install and start Nginx  
- Host a basic custom HTML webpage  

---

## 🧱 Project Structure Overview

This project is divided into three key phases, each representing a progressive step in automating and scaling web hosting on AWS EC2:
```
nginx-aws-project/
│
├── docs/
│   ├── 1-nginx-setup.md           # Manual Nginx setup on AWS EC2 (this file)
│   ├── 2-ansible-automation.md    # Automating multi-instance setup with Ansible
│   └── 3-monitoring-setup.md       # Monitoring setup with Prometheus + Grafana

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
![Custom Web Page Running](/screenshots/Custom-webpage.png)
## Additional Screenshots
Here are some extra screenshots showing the setup process and server status:

- **EC2 Instance Running:**  
  ![EC2 Running](/screenshots/ec2-running.png)

- **SSH Connection to EC2:**  
  ![SSH Connection](/screenshots/ssh-connection.png)

- **Installing Nginx:**  
  ![Installing Nginx](/screenshots/installing-nginx.png)

- **Nginx Service Status:**  
  ![Nginx Status](/screenshots/nginx-status.png)

## 🔁 Related Phases
	•	2 — Ansible Automation Setup￼ (next step: automate EC2 + Nginx deployment)
	•	3 — Monitoring Setup (Prometheus + Grafana)￼ (real-time monitoring of both EC2 instances)

---

### 🧭 Notes & Next Steps

This phase (manual setup) lays the foundation for:
	•	Automating server configuration via Ansible
	•	Extending to multi-instance orchestration
	•	Adding Prometheus + Grafana monitoring

>📚 This file is part of the documentation series under /docs/
Next: [Ansible Automation Setup](/ansible-project/README.md) →￼