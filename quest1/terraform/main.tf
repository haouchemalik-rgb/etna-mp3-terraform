terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
  # Identifiants issus de la chaîne standard AWS (profil CLI, variables
  # d'environnement ou rôle IAM) : aucune clé ne transite par Terraform.
  profile = var.aws_profile
}
