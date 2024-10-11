# Instance EC2 pour le déploiement de la clé ssh
resource "aws_key_pair" "deploy_key" {
  key_name   = "id_rsa.pub"
  public_key = file(var.filePath)
}

# Instance EC2 pour le groupe de sécurité
resource "aws_security_group" "allow_all" {
  name        = "allow_all_traffic"
  description = "Permet tout le trafic entrant et sortant"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Interface réseau pour le reverse proxy
resource "aws_network_interface" "reverse_proxy_nic" {
  subnet_id       = aws_subnet.internal.id
  private_ips     = ["192.168.1.10"]
  security_groups = [aws_security_group.allow_all.id]
  tags = {
    Name = "reverse_proxy_nic"
  }
}

# Instance reverse_proxy utilisant l'interface réseau
resource "aws_instance" "reverse_proxy" {
  ami                    = "ami-0314c062c813a4aa0"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deploy_key.key_name

  network_interface {
    network_interface_id = aws_network_interface.reverse_proxy_nic.id
    device_index         = 0
  }

  root_block_device {
    volume_size           = 8
    delete_on_termination = true
    volume_type           = "gp2"
  }
}

# Interface réseau pour backend1
resource "aws_network_interface" "backend1_nic" {
  subnet_id       = aws_subnet.internal.id
  private_ips     = ["192.168.1.20"]  # Adresse IP privée pour backend1
  security_groups = [aws_security_group.allow_all.id]
  tags = {
    Name = "backend1_nic"
  }
}

# Instance backend1
resource "aws_instance" "backend1" {
  ami           = "ami-0314c062c813a4aa0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deploy_key.key_name

  network_interface {
    network_interface_id = aws_network_interface.backend1_nic.id
    device_index         = 0
  }

  root_block_device {
    volume_size           = 8
    delete_on_termination = true
    volume_type           = "gp2"
  }
}

# Interface réseau pour backend2
resource "aws_network_interface" "backend2_nic" {
  subnet_id       = aws_subnet.internal.id
  private_ips     = ["192.168.1.30"]  # Adresse IP privée pour backend2
  security_groups = [aws_security_group.allow_all.id]
  tags = {
    Name = "backend2_nic"
  }
}

# Instance backend2
resource "aws_instance" "backend2" {
  ami           = "ami-0314c062c813a4aa0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deploy_key.key_name

  network_interface {
    network_interface_id = aws_network_interface.backend2_nic.id
    device_index         = 0
  }

  root_block_device {
    volume_size           = 8
    delete_on_termination = true
    volume_type           = "gp2"
  }
}

# Interface réseau pour database
resource "aws_network_interface" "database_nic" {
  subnet_id       = aws_subnet.internal.id
  private_ips     = ["192.168.1.40"]  # Adresse IP privée pour database
  security_groups = [aws_security_group.allow_all.id]
  tags = {
    Name = "database_nic"
  }
}

# Instance database
resource "aws_instance" "database" {
  ami           = "ami-0314c062c813a4aa0"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deploy_key.key_name

  network_interface {
    network_interface_id = aws_network_interface.database_nic.id
    device_index         = 0
  }

  root_block_device {
    volume_size           = 8
    delete_on_termination = true
    volume_type           = "gp2"
  }
}

output "reverse_proxy_public_ip" {
  value = aws_instance.reverse_proxy.public_ip
}
