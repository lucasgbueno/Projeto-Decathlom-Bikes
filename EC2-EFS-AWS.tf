terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.48.0"
    }
  }
}

provider "aws" {
  region                   = "us-east-1"
  shared_config_files      = ["C:/Users/admin/.aws/config"]
  shared_credentials_files = ["C:/Users/admin/.aws/credentials"]
}

# Definição do script de inicialização
variable "custom_data_script" {
  default = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nfs-common
              EOF
}

resource "aws_security_group" "instance_sg" {
  name        = "instance-efs-sg"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = "vpc-08e93608cbfe1a2f2"

  ingress {
    from_port   = 22
    to_port     = 22
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

# Criar EC2 Linux
resource "aws_instance" "linux_EFS" {
  count                       = 2
  ami                         = "ami-04ff98ccbfa41c9ad" # Amazon linux 2
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-05094be3cbd7c5361"
#  key_name                    = "vockey" # Não esqueca de gerar a chave  pública e privada para este nome!
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.instance_sg.id}"]
  user_data                   = var.custom_data_script
  tags = {
    Name = "Linux-EFS-${count.index}"
  }
}

output "security_group_id" {
  value = aws_security_group.instance_sg.id
}

# Exibir IP público das maquinas
output "instance_ips" {
  description = "IP Publico da Instancia EC2 linux"
  value       = aws_instance.linux_EFS[*].public_ip
}

