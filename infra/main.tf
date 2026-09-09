provider "aws" {
  region = "us-east-1"
}

# Security group
resource "aws_security_group" "vibe_sg" {
  name        = "vibe-sg"
  description = "Allow SSH, HTTP, HTTPS"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # replace with your actual public IP
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
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

# Key pair (use an existing public key)
resource "aws_key_pair" "vibe_key" {
  key_name   = "vibe-key"
  public_key = file("/home/sujal/.ssh/vibe-key.pub")
}

# EC2 instance
resource "aws_instance" "vibe_server" {
  ami                    = "ami-05a3e9423ae4d7a19"  # Ubuntu 22.04 LTS, us-east-1 — verify this is current
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.vibe_key.key_name
  vpc_security_group_ids = [aws_security_group.vibe_sg.id]

  tags = {
    Name = "vibe-server"
  }
}

# Elastic IP
resource "aws_eip" "vibe_eip" {
  instance = aws_instance.vibe_server.id
  domain   = "vpc"
}

output "public_ip" {
  value = aws_eip.vibe_eip.public_ip
}