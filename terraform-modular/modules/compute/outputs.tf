output "private_ip" {
  value       = aws_instance.web_server.private_ip
  description = "The target private IP address for Ansible configuration"
}

output "alb_dns" {
  value       = aws_lb.external_alb.dns_name
  description = "The public web address to access your application"
}