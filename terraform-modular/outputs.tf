output "app_server_private_ip" {
  value = module.compute.private_ip
}

output "load_balancer_url" {
  value = module.compute.alb_dns
}