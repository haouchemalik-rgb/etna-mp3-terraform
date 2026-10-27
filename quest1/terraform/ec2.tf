# Instance EC2 pour le déploiement de la clé ssh
resource "aws_key_pair" "deploy_key" {
  key_name   = "deploy_key"
  public_key = file(var.filePath)
}

# ---------------------------------------------------------------------------
# Groupes de sécurité : moindre privilège, un groupe par rôle
# ---------------------------------------------------------------------------

# Reverse proxy : seul point d'entrée depuis Internet (HTTP/HTTPS),
# SSH réservé à l'IP d'administration. Il sert aussi de bastion SSH.
resource "aws_security_group" "reverse_proxy" {
  name        = "sg_reverse_proxy"
  description = "HTTP HTTPS publics, SSH depuis IP admin"
  vpc_id      = aws_vpc.main.id

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

  ingress {
    description = "SSH administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    description = "Sortant (mises a jour, trafic vers les backends)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Backends : port applicatif uniquement depuis le reverse proxy,
# SSH uniquement en rebond depuis le bastion.
resource "aws_security_group" "backend" {
  name        = "sg_backend"
  description = "Application depuis reverse proxy, SSH via bastion"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Application depuis le reverse proxy"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.reverse_proxy.id]
  }

  ingress {
    description     = "SSH via le bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.reverse_proxy.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Base de données : port SGBD uniquement depuis les backends.
resource "aws_security_group" "database" {
  name        = "sg_database"
  description = "SGBD depuis backends, SSH via bastion"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SGBD depuis les backends"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.backend.id]
  }

  ingress {
    description     = "SSH via le bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.reverse_proxy.id]
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
  security_groups = [aws_security_group.reverse_proxy.id]
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
  security_groups = [aws_security_group.backend.id]
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
  security_groups = [aws_security_group.backend.id]
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
  security_groups = [aws_security_group.database.id]
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
