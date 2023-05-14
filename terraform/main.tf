provider "aws" {
  region = "us-east-2"
}

locals {
  key_name        = "id_rsa"
  instance_type   = "t2.small"
  ami_id          = "ami-0a695f0d95cefc163" # Ubuntu 20.04 LTS
}

resource "aws_key_pair" "dokku_key" {
  key_name   = local.key_name
  public_key = file("~/.ssh/${local.key_name}.pub")
}

resource "aws_security_group" "dokku_sg" {
  name = "dokku_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "dokku" {
  ami           = local.ami_id
  instance_type = local.instance_type
  key_name      = aws_key_pair.dokku_key.key_name
  vpc_security_group_ids = [aws_security_group.dokku_sg.id]

  tags = {
    Name = "dokku-instance"
  }
}
