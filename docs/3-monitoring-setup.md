# 📊 Monitoring Setup — Prometheus + Grafana

This document provides the **complete step-by-step setup guide** for implementing a monitoring solution using **Prometheus**, **Node Exporter**, and **Grafana** across two EC2 instances.

---

## 🧩 Overview

The goal of this setup is to monitor **CPU, memory, disk, and network usage** in real time across multiple EC2 instances.

| Component | Description | Port |
|------------|-------------|------|
| **Prometheus** | Collects (scrapes) metrics from Node Exporters | 9090 |
| **Node Exporter** | Exposes system metrics (CPU, memory, disk) | 9100 |
| **Grafana** | Visualizes Prometheus data in dashboards | 3000 |

---

## 🏗️ Architecture Diagram
```
[ Debian EC2 Instance ]
├── Prometheus (port 9090)
├── Grafana (port 3000)
└── Node Exporter (port 9100)
↑
│ VPC Peering
↓
[ Red Hat EC2 Instance ]
└── Node Exporter (port 9100)
```
Prometheus scrapes metrics from **both Node Exporters**,  
and Grafana visualizes them securely through an **SSH tunnel**.

---


> **Live demo note:** In my actual AWS environment, I used a real private target IP during the run.
> This repo uses placeholders so others can reproduce safely with their own infra values.

## ⚙️ Step-by-Step Configuration

### 1. Install Node Exporter on Both EC2 Instances
Download, extract, and move the binary:
```bash
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz
tar -xvzf node_exporter-1.9.1.linux-amd64.tar.gz
sudo mv node_exporter-1.9.1.linux-amd64/node_exporter /usr/local/bin/
```
Create a dedicated system user and service file:
```bash
sudo useradd -rs /sbin/nologin node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
```
**file** /etc/systemd/system/node_exporter.service
```ini
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
```
Enable and start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
```
### 2. Verify Node Exporter
Confirm that it’s running and listening on port 9100: 
```bash
sudo systemctl status node_exporter
ss -tuln | grep 9100
```
Test the metrics endpoint:
```bash
curl http://localhost:9100/metrics
```
### 3. Install Prometheus on Debian EC2
```bash
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v3.7.1/prometheus-3.7.1.linux-amd64.tar.gz
tar -xvzf prometheus-3.7.1.linux-amd64.tar.gz
sudo mv prometheus-3.7.1.linux-amd64 /usr/local/bin/prometheus
```
Create user, directories, and permissions:
```bash
sudo useradd -rs /sbin/nologin prometheus
sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo mv /usr/local/bin/prometheus/prometheus.yml /etc/prometheus/
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
```
### 4. Configure Prometheus

**file** /etc/prometheus/prometheus.yml
```yaml
global:
  scrape_interval: 10s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node_exporter"
    scrape_interval: 10s
    static_configs:
      - targets: ["localhost:9100", "<redhat-private-ip>:9100"]
```
### 5. Create Prometheus Service
**file** /etc/systemd/system/prometheus.service
```ini
[Unit]
Description=Prometheus Monitoring
After=network.target

[Service]
User=prometheus
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus/
Restart=always

[Install]
WantedBy=multi-user.target
```
Reload and start:
```bash
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
```
### 6. Verify Prometheus Targets
```bash
curl http://localhost:9090/targets
```
You should see both Node Exporter endpoints listed as UP.

### 7. Install Grafana
Add Grafana’s official GPG key and repository to your APT sources:
Official Grafana installation guide: [Grafana Docs](https://grafana.com/docs/grafana/latest/setup-grafana/installation/debian/)
```bash
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install grafana -y
```
Start and enable Grafana:
```bash
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
```
### 8. Access Grafana Securely

Forward local port 3000 to the Debian EC2 instance:
```bash
ssh -L 3000:localhost:3000 ubuntu@<debian-public-ip>
```
Open Grafana in your browser:
👉 http://localhost:3000
Default credentials: admin / admin (you’ll be prompted to change it on first login).

⸻

### 9. Add Prometheus as Data Source
	•	Go to Settings → Data Sources → Add new
	•	Choose Prometheus
	•	URL: http://localhost:9090
	•	Click Save & Test

⸻

### 10. Import Dashboard

Import prebuilt Node Exporter Full Dashboard (ID: 1860)

Dashboard → Import → Enter ID → Select Prometheus data source

⸻

### 📸 Screenshots

- Grafana Dashboard Overview:
![Grafana Dashboard Overview](/monitoring/grafana/screenshots/grafana-dashboard-overview.png) 
  
- Instance selector:
![Instance selector](/monitoring/grafana/screenshots/grafana-instance-selector.png)￼

- Prometheus Targets UP:
![Prometheus Targets UP](/monitoring/grafana/screenshots/prometheus-targets-up.png)￼

⸻

### ✅ Outcome
	•	Real-time CPU, memory, disk, and network visibility
	•	Cross-VPC observability via peering
	•	Secure, tunnel-based access (no exposed ports)
	•	Ready foundation for automation and alerting

🧭 Summary: See [Monitoring Overview](/monitoring/README.md)￼ for architecture and outcomes.￼