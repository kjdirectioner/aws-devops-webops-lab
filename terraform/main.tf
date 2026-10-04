resource "aws_instance" "demo" {
  ami           = var.ami
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "My_Webserver"
  }
}

resource "aws_security_group" "web_sg" {
  name = "web_sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}

output "instance_ip" {
  value = aws_instance.demo.public_ip
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}


resource "local_file" "ansible_inventory" {
  content = <<EOT
[web_servers]
${aws_instance.demo.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/your-key.pem

[monitoring]
${aws_instance.demo.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/your-key.pem
EOT

  filename = "../ansible-project/inventory.generated.ini"
}

