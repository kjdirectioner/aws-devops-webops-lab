# 🐳 07 — Docker on Cloud-Init + Compose Web and Monitoring Stack

This phase extends the Docker deployment from a single Nginx container to a Compose project for the web and monitoring services.

---

## 🧭 Documentation Path

```text
01 Manual EC2 + Nginx setup
   -> 02 Ansible automation
   -> 03 Monitoring setup
   -> 04 Terraform import setup
   -> 05 Manual network re-architecture
   -> 06 Terraform modular refactor
   -> 07 Docker on cloud-init + Compose web and monitoring stack  ← you are here
```

Previous: [06 — Terraform Modular Refactor](./6-terraform-modular.md)

Project overview: [Main README](../README.md)

---

## 🧩 Why Docker, Why Now

Through Phase 06, every Ansible playbook run installs Nginx from apt on the target instance at deploy time. That works, but it has real costs:

- Package installation, dependency resolution, and service setup happen on every deploy, adding latency
- The deployment is dependent on apt mirrors being reachable and responsive
- Each service (Nginx, Node Exporter, Prometheus, Grafana) is managed as a separate systemd unit with its own install path

The eventual goal is CI/CD — automated deploys on every push to main. A slow, apt-install-at-deploy-time playbook is a poor fit for that. Container images are built once and deploying one is just running a pre-built artefact — consistently fast and much lighter on external dependencies at deploy time.

This phase builds on that proof of concept:

1. **Validates that cloud-init correctly bootstraps the Docker daemon** — Docker is installed on the instance automatically at first boot, via Terraform's `user_data`, so no Ansible task or manual step is needed to prepare the instance for containers.
2. **Runs the web and monitoring services as a Compose project** — Nginx is built from the local Dockerfile, while Prometheus, Grafana, and Node Exporter use versioned images. Compose keeps their configuration and lifecycle together in one project directory.

---

## 🏗️ How Cloud-Init Bootstraps Docker

Docker is not installed by Ansible. It is installed by Terraform at the moment the EC2 instance first boots, via the `user_data` field:

```tf
# terraform-modular/modules/compute/main.tf
resource "aws_instance" "web_server" {
  ...
  user_data                   = file("${path.module}/install_docker.sh")
  user_data_replace_on_change = true
}
```

`install_docker.sh` runs once on first boot:

```bash
apt-get update -y
apt-get install -y curl
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu
systemctl enable docker
systemctl start docker
```

By the time Ansible connects — after `terraform apply` completes and the instance passes its ALB health checks — Docker is already installed and the daemon is running. `user_data_replace_on_change = true` means that if this script is ever edited, Terraform will recreate the instance on the next `apply` so the new script actually executes. Without this flag, a running instance silently ignores any changes to `user_data`.

---

## 🗂️ Key Files

| File | Purpose |
|------|---------|
| `terraform-modular/modules/compute/install_docker.sh` | Cloud-init script: installs Docker engine, adds `ubuntu` to the docker group, starts and enables the daemon |
| `docker/nginx/Dockerfile` | Builds `custom-nginx` from `nginx:1.27-alpine` with `index.html` baked in at build time |
| `docker/nginx/index.html` | The static page served by the container |
| `docker/docker-compose.yml` | Defines the Nginx, Prometheus, Grafana, and Node Exporter services |
| `docker/monitor/prometheus.yml` | Configures Prometheus to scrape itself and Node Exporter |
| `docker/grafana/datasource/datasource.yml` | Provisions Prometheus as Grafana's default data source |
| `ansible-project/docker_deploy.yml` | Playbook that applies the `docker_stack` role to the `web_servers` group |
| `ansible-project/roles/docker_stack/tasks/main.yml` | Creates `/opt/nginx-docker`, copies the build context, builds `custom-nginx`, runs it as container `web-server` on port 80 |
| `ansible-project/compose_deploy.yml` | Playbook that applies the Compose stack role |
| `ansible-project/roles/docker_compose_stack/tasks/main.yml` | Installs the Compose plugin, copies the Compose project, starts it, and checks service endpoints |

---

## 🚀 Deploy the Compose Stack

Same inventory and connection path as every other playbook — the EICE tunnel is handled automatically by `ansible.cfg`:

```bash
ansible-playbook -i ansible-project/inventory.ini ansible-project/compose_deploy.yml
```

The role copies the full `docker/` directory to `/opt/webops-stack/`, then calls `community.docker.docker_compose_v2` with `state: present`. This brings up the services described by the Compose file. Docker Compose v2 must be available on the host, and the `community.docker` collection must be installed on the Ansible control machine.

> **Existing services can conflict:** the apt Nginx and monitoring playbooks, and the standalone `docker_deploy.yml` path, may already occupy the ports used by Compose. Before the first Compose deployment, check the host and stop the old services or containers you no longer intend to use. Keep to one deployment path for these services on a host.
> ```bash
> sudo systemctl stop nginx
> ```

---

## ✅ Validation

The Compose deployment role checks the local Nginx, Prometheus, and Grafana endpoints. You can inspect the project on the instance through EICE:

```bash
docker compose -f /opt/webops-stack/docker-compose.yml ps
docker compose -f /opt/webops-stack/docker-compose.yml logs --tail=50
```

Through the ALB — the load balancer only checks that port 80 is responding, so it is unaware of whether apt-installed Nginx or a container is answering:

```bash
curl http://$(terraform -chdir=terraform-modular output -raw load_balancer_url)
```

Expected result: the Phase 01 page is served through the ALB by the Compose-managed Nginx service. Prometheus should report its own target and Node Exporter as healthy. Grafana's provisioned Prometheus data source points to `http://prometheus:9090` on the Compose network.

---

## 🧭 What This Proves

- Cloud-init correctly bootstraps the Docker daemon before Ansible connects — no manual prep step and no race condition
- Ansible can copy the Compose project and manage it through the Docker Compose v2 module over the EICE connection
- The container surfaces identically through the ALB — no changes to the network layer, security groups, or target group were needed
- Prometheus and Grafana keep their application data in named Docker volumes
- The project now has separate apt, standalone-container, and Compose deployment paths; only one path for a given service should be active on the instance

---

## 🧭 Next Step

Next, validate the Compose services and Prometheus targets on the EC2 instance. Further improvements could include a Grafana dashboard and a documented private access path for the monitoring interfaces.

---

>📚 This file is part of the documentation series under /docs/
Back to project overview: [Main README](../README.md)
