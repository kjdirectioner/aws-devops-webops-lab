# 🛡️ 05 — Manual Zero-Exposure Network Re-Architecture

This document explains the network redesign that moved the project from a single, publicly-exposed EC2 instance to a multi-tier VPC with no direct public exposure on the compute layer. This phase was carried out by hand in the AWS Console to work through the routing and security-group mechanics before codifying it as Terraform in Phase 06.

---

## 🧭 Documentation Path

```text
01 Manual EC2 + Nginx setup
   -> 02 Ansible automation
   -> 03 Monitoring setup
   -> 04 Terraform import setup
   -> 05 Manual network re-architecture  ← you are here
   -> 06 Terraform modular refactor
```

Previous: [04 — Terraform Import Setup](./4-terraform-setup.md)

Next: [06 — Terraform Modular Refactor](./6-terraform-modular.md)

---

## 🧩 Overview

Through Phase 04, the project's Ubuntu EC2 instance lived in a default VPC with a public IP, and its own security group allowed SSH from `0.0.0.0/0`. That was fine for getting infrastructure under Terraform quickly, but it's not how a real web tier should be exposed.

This phase re-architects the network by hand to enforce strict tier isolation, before any of it is written as Terraform:

- public subnets across two Availability Zones, used only by the load balancer and the access endpoint
- a private subnet with no public IP, used by the Nginx/monitoring instance
- an Application Load Balancer as the single public entry point for web traffic
- an EC2 Instance Connect Endpoint (EICE) as the single path for administrative access, replacing an open SSH rule

## 🏗️ Architecture

![Phase 05 architecture diagram](../screenshots/phase6-architecture.png)

```text
Ubuntu EC2 (Public Subnet)              ->      Multi-Tier VPC
  ├── Nginx (Port 80)                            ├── Public Subnets (2 AZs): ALB + EICE
  ├── Node Exporter (Port 9100)                   └── Private Subnet: EC2 (Nginx, Node Exporter,
  ├── Prometheus (Port 9090)                           Prometheus, Grafana) — no public IP
  └── Grafana (Port 3000)
```

### 🔄 Core Routing Dynamics

1. **Inbound traffic plane** — Public subnets in two Availability Zones satisfy the AWS requirement for an Application Load Balancer. The ALB is the single ingress point for internet traffic on port 80/443 and forwards down to the private backend.
2. **Compute isolation** — The Nginx web server and monitoring stack moved entirely into a private subnet with zero public IP footprint.
3. **Independent outbound path** — Package updates from the private instance resolve through the NAT Gateway in the public subnet, completely separate from the inbound EICE management tunnel.
4. **Zero-exposure management plane** — Public SSH (port 22) is fully closed. Administrative access tunnels through an EC2 Instance Connect Endpoint sitting in the public subnet instead of a directly reachable port on the instance.

## 🔐 Security Model

| Plane | Old (Phase 04) | New (Phase 05) |
|-------|-----------------|------------------|
| Web traffic | Direct to instance public IP, port 80 | Through ALB only |
| SSH/admin | Open `22` from `0.0.0.0/0` | Closed; routed through EICE |
| Instance visibility | Public IP | No public IP, private subnet only |
| Outbound updates | Direct internet route | Through NAT Gateway |

## 🎯 Expected Outcome

- No service on the compute instance is directly reachable from the internet
- All web traffic funnels through a single, health-checked ALB
- All administrative access funnels through a single, auditable EICE endpoint
- The network shape matches what's expected of a production web tier, not just a sandbox

## 🧭 Notes

- This phase was done manually in the AWS Console to validate the routing and security-group design before committing to code — the same "prove it by hand first" approach used in Phase 01 before Ansible automated it.
- Because this was manual, it isn't reproducible from source yet. That gap is closed in the next phase.

---

## 🧭 Next Step

With the network topology proven by hand, the next phase codifies this exact design as reusable Terraform modules, so it can be destroyed and rebuilt from code instead of AWS Console clicks.

>📚 This file is part of the documentation series under /docs/
Next: [06 — Terraform Modular Refactor](./6-terraform-modular.md) →