output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "app_sg_id" {
  value = aws_security_group.app_sg.id
}

output "eice_sg_id" {
  value = aws_security_group.eice_sg.id
}