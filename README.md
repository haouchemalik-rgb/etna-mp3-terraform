# Infrastructure AWS en Terraform — reverse proxy, backends et base de données

> Projet ETNA — module MP3 « Infrastructure as Code » · Projet en binôme

Provisionnement d'une architecture 3-tiers sur **AWS (région Paris, eu-west-3)** entièrement décrite en **Terraform** : un VPC dédié, un sous-réseau, un reverse proxy exposé, deux serveurs applicatifs et un serveur de base de données sur adresses privées fixes.

**Compétences mises en œuvre :** Terraform · AWS (VPC, Subnet, Internet Gateway, Route Table, Network ACL, Security Group, EC2, Key Pair) · adressage IP · documentation d'installation

---

## Architecture

```
                Internet
                    │
            Internet Gateway
                    │
  VPC 192.168.0.0/16 ─ sous-réseau 192.168.1.0/24 (eu-west-3a)
     ├── reverse_proxy  192.168.1.10  (IP publique)
     ├── backend1       192.168.1.20
     ├── backend2       192.168.1.30
     └── database       192.168.1.40
```

| Fichier | Contenu |
|---|---|
| [`quest1/terraform/main.tf`](quest1/terraform/main.tf) | Provider AWS et contraintes de version |
| [`quest1/terraform/vpc.tf`](quest1/terraform/vpc.tf) | VPC, Internet Gateway, sous-réseau, table de routage, Network ACL |
| [`quest1/terraform/ec2.tf`](quest1/terraform/ec2.tf) | Clé SSH, Security Group, interfaces réseau et 4 instances EC2 |
| [`quest1/terraform/variables.tf`](quest1/terraform/variables.tf) | Variables (identifiants AWS, chemin de la clé publique) |
| [`quest1/documentation/`](quest1/documentation/) | Guide d'installation (Linux / macOS / Windows) et schéma d'architecture |
| [`quest1/questions_de_cours/`](quest1/questions_de_cours/) | Réponses aux questions théoriques (IaC, VPC, ACL, Security Groups…) |

## Utilisation

```bash
cd quest1/terraform
cat > terraform.tfvars <<EOF
aws_access_key = "..."
aws_secret_key = "..."
EOF
terraform init
terraform plan
terraform apply
```

Les identifiants AWS sont passés par variables (`terraform.tfvars`, exclu du dépôt) et ne sont jamais versionnés ; l'état Terraform (`.tfstate`) est également ignoré.

## Limites connues et améliorations prévues

Ce projet répondait à un sujet pédagogique centré sur le provisionnement. Pour une mise en production, je durcirais :

- **Security Group** : remplacer la règle « tout le trafic » par des règles minimales (443 vers le reverse proxy, ports applicatifs uniquement depuis le proxy, port BDD uniquement depuis les backends, SSH depuis une IP d'administration ou un bastion).
- **Segmentation** : sous-réseau public pour le reverse proxy, sous-réseaux privés + NAT Gateway pour les backends et la base.
- **Identifiants** : profil AWS CLI ou rôle IAM plutôt que des clés passées en variables ; backend d'état distant (S3 + verrouillage DynamoDB).
