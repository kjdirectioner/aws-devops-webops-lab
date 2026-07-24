module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

module "compute" {
  source             = "./modules/compute"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  alb_sg_id          = module.security_groups.alb_sg_id
  app_sg_id          = module.security_groups.app_sg_id
  eice_sg_id         = module.security_groups.eice_sg_id
  ami                = var.ami
  instance_type      = var.instance_type
}

resource "local_file" "ansible_inventory" {
  content  = <<EOT
[web_servers]
# private_ip: ${module.compute.private_ip}
web-server-1 ansible_host=${module.compute.instance_id}

[monitoring]
# private_ip: ${module.compute.private_ip}
monitor-1 ansible_host=${module.compute.instance_id}
EOT
  filename = "../ansible-project/inventory.ini"
}