terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.48.0"
    }
  }
}

provider "aws" {
 region = "us-east-1"
 shared_config_files=["./aws/config"]
 shared_credentials_files=["./aws/config"]
}

# Definição do script de inicialização
variable "custom_data_script" {
  default = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y nfs-utils
              sudo mkdir /mnt/efs
              sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-03feb458a214b755e.efs.us-east-1.amazonaws.com:/ /mnt/efs
              EOF
}

# Criar EC2 Linux
resource "aws_instance" "linux_EFS_1" {
  ami                         = "ami-04ff98ccbfa41c9ad" # Amazon linux 2
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-08fedf52cca8dde8f"
  key_name                    = "vockey" # Não esqueca de gerar a chave  pública e privada para este nome!
  associate_public_ip_address = true
  vpc_security_group_ids      = ["sg-0c1f6f466d3838230"] #["${aws_security_group.instance_sg.id}"]
  user_data                   = var.custom_data_script
  tags = {
    Name = "Linux-EFS-1"
  }
}

resource "aws_instance" "linux_EFS_2" {
  ami                         = "ami-04ff98ccbfa41c9ad" # Amazon linux 2
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-08fedf52cca8dde8f"
  key_name                    = "vockey" # Não esqueca de gerar a chave  pública e privada para este nome!
  associate_public_ip_address = true
  vpc_security_group_ids      = ["sg-0c1f6f466d3838230"] #["${aws_security_group.instance_sg.id}"]
  user_data                   = var.custom_data_script
  tags = {
    Name = "Linux-EFS-2"
  }
}

# Exibir IP público das maquinas
output "instance_ip_1" {
  description = "IP Publico da 1 Instancia EC2 linux"
  value       = aws_instance.linux_EFS_1.public_ip
}

# Exibir IP público das maquinas
output "instance_ip_2" {
  description = "IP Publico da 2 Instancia EC2 linux"
  value       = aws_instance.linux_EFS_2.public_ip
}

