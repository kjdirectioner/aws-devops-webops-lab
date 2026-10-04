#!/bin/bash
# Update and install dependencies
apt-get update -y
apt-get install -y curl

# Fetch and execute the official Docker installation script
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Grant the default ubuntu user Docker privileges to prevent permissions issues for Ansible
usermod -aG docker ubuntu

# Force systemd to enable and start the Docker daemon
systemctl enable docker
systemctl start docker