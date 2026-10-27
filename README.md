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
| [`quest1/terraform/ec2.tf`](quest1/terraform/ec2.tf) | Clé SSH, 3 groupes de sécurité par rôle, interfaces réseau et 4 instances EC2 |
| [`quest1/terraform/variables.tf`](quest1/terraform/variables.tf) | Variables (profil AWS, clé SSH, IP d'administration, ports) |
| [`quest1/documentation/`](quest1/documentation/) | Guide d'installation (Linux / macOS / Windows) et schéma d'architecture |
| [`quest1/questions_de_cours/`](quest1/questions_de_cours/) | Réponses aux questions théoriques (IaC, VPC, ACL, Security Groups…) |

## Sécurité réseau

Un groupe de sécurité par rôle, sur le principe du moindre privilège :

| Groupe | Entrant autorisé |
|---|---|
| `sg_reverse_proxy` | 80 / 443 depuis Internet · 22 depuis `admin_cidr` uniquement |
| `sg_backend` | port applicatif et SSH **depuis le reverse proxy uniquement** (bastion) |
| `sg_database` | port SGBD depuis les backends · SSH depuis le bastion |

La Network ACL du sous-réseau (sans état) n'ouvre que SSH depuis `admin_cidr`, HTTP/HTTPS, le trafic interne au VPC et les ports éphémères de retour. Une règle de validation refuse `admin_cidr = 0.0.0.0/0`.

## Utilisation

```bash
aws configure --profile etna              # identifiants stockés par l'AWS CLI, hors du dépôt
cd quest1/terraform
terraform init
terraform plan  -var aws_profile=etna -var filePath=~/.ssh/deploy.pub -var admin_cidr=$(curl -s https://checkip.amazonaws.com)/32
terraform apply -var aws_profile=etna -var filePath=~/.ssh/deploy.pub -var admin_cidr=$(curl -s https://checkip.amazonaws.com)/32
```

Aucune clé AWS ne passe par Terraform (chaîne d'identifiants standard : profil CLI, variables d'environnement ou rôle IAM). L'état Terraform (`.tfstate`) et les fichiers `*.tfvars` sont exclus du dépôt.

## Améliorations possibles

- **Segmentation** : sous-réseau public pour le reverse proxy, sous-réseaux privés + NAT Gateway pour les backends et la base (aujourd'hui un seul sous-réseau, filtré par groupes de sécurité).
- **État distant** : backend S3 chiffré avec verrouillage DynamoDB pour le travail en équipe.
- **Accès d'administration** : AWS Systems Manager Session Manager à la place du bastion SSH.
