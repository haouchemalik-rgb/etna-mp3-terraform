variable "aws_profile" {
  description = "Profil AWS CLI à utiliser (identifiants lus dans ~/.aws, jamais dans le code)"
  type        = string
  default     = "default"
}

variable "filePath" {
  description = "Chemin de la clé SSH publique de déploiement"
  type        = string
}

variable "admin_cidr" {
  description = "Plage autorisée en SSH vers le bastion, par ex. 203.0.113.10/32"
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0)) && var.admin_cidr != "0.0.0.0/0"
    error_message = "admin_cidr doit être un CIDR valide et ne peut pas être 0.0.0.0/0."
  }
}

variable "app_port" {
  description = "Port applicatif des backends"
  type        = number
  default     = 80
}

variable "db_port" {
  description = "Port du SGBD (3306 pour MySQL/MariaDB)"
  type        = number
  default     = 3306
}
