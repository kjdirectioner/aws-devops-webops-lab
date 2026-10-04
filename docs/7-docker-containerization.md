# 🐳 07 — Docker on Cloud-Init + Containerised Nginx (Proof of Concept)

This document explains why Docker was introduced at this stage, how the daemon gets onto the instance automatically via cloud-init, and what the containerised Nginx deployment proves — about the environment and about the deployment strategy going forward.

---

## 🧭 Documentation Path

```text
01 Manual EC2 + Nginx setup
   -> 02 Ansible automation
   -> 03 Monitoring setup
   -> 04 Terraform import setup
   -> 05 Manual network re-architecture
   -> 06 Terraform modular refactor
   -> 07 Docker on cloud-init + containerised Nginx (proof of concept)  ← you are here
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

This phase does two targeted things as a proof of concept:

1. **Validates that cloud-init correctly bootstraps the Docker daemon** — Docker is installed on the instance automatically at first boot, via Terraform's `user_data`, so no Ansible task or manual step is needed to prepare the instance for containers.
2. **Containerises Nginx as a test case** — the same static page from Phase 01 is now served from inside a Docker container built on the instance by Ansible, proving the daemon is correctly initialised and that Ansible can build and run images through it.

This is not the end state. It is the foundation check before the next step: replacing the individually apt-installed monitoring components (Node Exporter, Prometheus, Grafana) with a single Docker Compose stack — one command to bring the whole observability layer up or tear it down.

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
| `docker/docker-compose.yml` | Local compose reference for manual build/run testing on a dev machine — not used by Ansible |
| `ansible-project/docker_deploy.yml` | Playbook that applies the `docker_stack` role to the `web_servers` group |
| `ansible-project/roles/docker_stack/tasks/main.yml` | Creates `/opt/nginx-docker`, copies the build context, builds `custom-nginx`, runs it as container `web-server` on port 80 |

---

## 🚀 Run the Docker Playbook

Same inventory and connection path as every other playbook — the EICE tunnel is handled automatically by `ansible.cfg`:

```bash
ansible-playbook -i ansible-project/inventory.ini ansible-project/docker_deploy.yml
```

> **Port 80 conflict:** `playbook.yml` (apt Nginx) and `docker_deploy.yml` (containerised Nginx) both bind port 80. Do not run both against the same host. If switching from the apt path to the container path, stop the Nginx service on the instance first before running `docker_deploy.yml`:
> ```bash
> sudo systemctl stop nginx
> ```

---

## ✅ Validation

On the instance (via EICE):

```bash
systemctl status docker
docker images        # should list custom-nginx
docker ps            # should show web-server running, 0.0.0.0:80->80/tcp
```

Through the ALB — the load balancer only checks that port 80 is responding, so it is unaware of whether apt-installed Nginx or a container is answering:

```bash
curl http://$(terraform -chdir=terraform-modular output -raw load_balancer_url)
```

Expected result: the same custom Nginx page from Phase 01, now served from inside the container.

---

## 🧭 What This Proves

- Cloud-init correctly bootstraps the Docker daemon before Ansible connects — no manual prep step and no race condition
- Ansible's `community.docker` modules (`docker_image`, `docker_container`) work correctly against that daemon through the EICE tunnel
- The container surfaces identically through the ALB — no changes to the network layer, security groups, or target group were needed
- The build-once-run-fast container pattern is viable on this instance, and the bootstrap mechanism is solid enough to extend to the full stack

---

## 🗺️ What's Next

With the Docker daemon proven via cloud-init and the container deployment path validated, the next step is to extend this pattern to the whole stack:

- **Docker Compose for the monitoring stack** — replace the individually apt-installed Node Exporter, Prometheus, and Grafana services with a single `docker-compose.yml`. One `docker compose up` to bring the full observability layer up; one `docker compose down` to tear it down cleanly. This also makes the monitoring config portable — it lives alongside the code rather than being scattered across systemd unit files.
- **CI/CD pipeline** — once both the app and monitoring layers are containerised, a GitHub Actions workflow can run `terraform fmt`/`validate`, `ansible-lint`, and `docker build` checks on every push to main, and eventually automate the deploy itself.

---

>📚 This file is part of the documentation series under /docs/
Back to project overview: [Main README](../README.md)