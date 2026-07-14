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

# 2. EC2 Instance Connect Endpoint
resource "aws_security_group" "eice_sg" {
  name        = "eice-sg"
  description = "Allows administrative proxy traffic"
  vpc_id      = var.vpc_id

  tags = { Name = "eice-sg" }
}
# 3. Isolated Application Server 
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


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "app-sg" }
}

# 4. The Independent Rules (This breaks the logic loop)

# Allow EICE to send traffic OUT to the App Server on Port 22
resource "aws_security_group_rule" "eice_to_app_egress" {
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eice_sg.id
  source_security_group_id = aws_security_group.app_sg.id
}

# Allow App Server to accept traffic IN from the EICE on Port 22
resource "aws_security_group_rule" "app_from_eice_ingress" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app_sg.id
  source_security_group_id = aws_security_group.eice_sg.id
}