# 1. The Isolated Compute Node
resource "aws_instance" "web_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[0] # Drops it cleanly into Private Subnet 1
  vpc_security_group_ids = [var.app_sg_id]           # Attaches the chained firewall

  tags = {
    Name = "Nginx-Private-Server"
  }
}

# 2. The Ingress Engine: Application Load Balancer
resource "aws_lb" "external_alb" {
  name               = "main-alb"
  internal           = false # Faces the public internet
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids # Spans both public subnets for HA

  tags = { Name = "main-alb" }
}

# 3. The Target Destination Pool
resource "aws_lb_target_group" "web_tg" {
  name     = "web-servers-tg"
  port     = 80 # This is where Nginx listens!
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "80"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# 4. Linking the Target Pool to the Instance
resource "aws_lb_target_group_attachment" "web_attachment" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_server.id
  port             = 80
}

# 5. The Public Front Ear: Listener Rule
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.external_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# 6. The Zero-Exposure Management Entry Point
resource "aws_ec2_instance_connect_endpoint" "eice" {
  subnet_id          = var.public_subnet_ids[0]
  security_group_ids = [var.eice_sg_id]

  tags = { Name = "main-eice" }
}