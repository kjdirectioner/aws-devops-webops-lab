# 📊 Monitoring — Prometheus + Grafana

This folder shows the observability phase of the project. After the web server was automated with Ansible, monitoring was added to prove the instance is running and measurable.

---

## 🧩 What This Adds

- **Node Exporter** collects host-level metrics
- **Prometheus** scrapes metrics from `localhost:9100`
- **Grafana** visualizes CPU, memory, disk, and network health

---

## 🏗️ Monitoring Stack

```text
Ubuntu EC2
  - Node Exporter
  - Prometheus
  - Grafana
```

Prometheus scrapes the local Node Exporter endpoint, and Grafana displays the metrics through dashboards.

---

## 🗂️ Key File

| File | Purpose |
|------|---------|
| `prometheus.yml` | Local Prometheus scrape configuration |
| `grafana/screenshots/` | Dashboard and target proof screenshots |

---

## 📸 Proof

Grafana shows the host metrics visually:

![Grafana dashboard](grafana/screenshots/grafana-dashboard-overview.png)

Prometheus confirms the exporter target is healthy:

This screenshot was taken during the earlier two-instance phase, so it shows two targets. The current setup now keeps monitoring on the same Ubuntu instance and scrapes locally.

![Prometheus targets marked UP](grafana/screenshots/prometheus-targets-up.png)

Extra proof:

- [Instance selector](grafana/screenshots/grafana-instance-selector.png)

---

## 📖 Detailed Setup

- [Monitoring setup doc](../docs/3-monitoring-setup.md)
