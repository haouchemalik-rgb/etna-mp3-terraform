# Création du VPC
resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

# Création de l'Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-gateway"
  }
}

# Création du sous-réseau
resource "aws_subnet" "internal" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "eu-west-3a"
  map_public_ip_on_launch = true
  tags = {
    Name = "internal-subnet"
  }
}

# Création de la table de routage
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "main-route-table"
  }
}

# Association de la table de routage au sous-réseau
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.internal.id
  route_table_id = aws_route_table.rt.id
}

# Création de la liste de contrôle d'accès (ACL)
resource "aws_network_acl" "acl" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-network-acl"
  }
}

# Création des règles pour l'ACL
# La NACL est sans état : il faut autoriser explicitement les réponses
# (ports éphémères) en plus des services exposés.
resource "aws_network_acl_rule" "allow_ssh_inbound" {
  network_acl_id = aws_network_acl.acl.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = var.admin_cidr
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "allow_http_inbound" {
  network_acl_id = aws_network_acl.acl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "allow_https_inbound" {
  network_acl_id = aws_network_acl.acl.id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "allow_vpc_inbound" {
  network_acl_id = aws_network_acl.acl.id
  rule_number    = 130
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = aws_vpc.main.cidr_block
}

resource "aws_network_acl_rule" "allow_ephemeral_inbound" {
  network_acl_id = aws_network_acl.acl.id
  rule_number    = 140
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "allow_all_outbound" {
  network_acl_id = aws_network_acl.acl.id
  rule_number     = 100
  egress          = true
  protocol        = "-1"
  rule_action     = "allow"
  cidr_block      = "0.0.0.0/0"
}

# Association de l'ACL avec le sous-réseau
resource "aws_network_acl_association" "acl_assoc" {
  subnet_id      = aws_subnet.internal.id
  network_acl_id = aws_network_acl.acl.id
}