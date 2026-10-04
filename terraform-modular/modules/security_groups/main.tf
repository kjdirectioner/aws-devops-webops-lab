# 1. Public Load Balancer Security Group
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allows public web inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "alb-sg" }
}

# 2. EC2 Instance Connect Endpoint (EICE) Security Group
resource "aws_security_group" "eice_sg" {
  name        = "eice-sg"
  description = "Allows administrative proxy traffic"
  vpc_id      = var.vpc_id

  # EICE doesn't require inbound rules from the internet, only outbound to your instances
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Can be restricted to VPC CIDR for tightening
  }

  tags = { Name = "eice-sg" }
}

# 3. Isolated Application Server Security Group (Chained)
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Shields isolated private applications"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.eice_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "app-sg" }
}