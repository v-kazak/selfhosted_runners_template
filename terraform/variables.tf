variable "token" {
  type        = string
  description = "OAuth-токен Яндекса"
  sensitive   = true
}

variable "cloud_id" {
  type        = string
  description = "ID облака"
  sensitive   = true
}

variable "folder_id" {
  type        = string
  description = "ID папки"
  sensitive   = true
}

variable "zone" {
  type        = string
  description = "ID зоны Яндекса"
  default     = "ru-central1-d"
}

variable "vps_count" {
  type        = number
  description = "Количество создаваемых виртуальных машин"
  default     = 1
}

variable "cores_count" {
  type        = number
  description = "Количество ядер"
  default     = 2
}

variable "memory_count" {
  type        = number
  description = "Количество ОЗУ в гигабайтах"
  default     = 2
}

variable "core_fraction" {
  type        = number
  description = "% от общей мощности ядра"
  default     = 20
}

variable "disc_type" {
  type        = string
  description = "Тип накопителя"
  default     = "network-hdd"
}

variable "disc_size" {
  type        = number
  description = "Объем диска в гигабайтах"
  default     = 15
}

variable "name" {
  type        = string
  description = "Имя виртуальной машины"
  default     = "server"
}


variable "platform_type" {
  type        = string
  description = "Тип платформы"
  default     = "standard-v3"
}

variable "nat" {
  type        = bool
  description = "Выдавать внешний IP виртуальной машине"
  default     = true
}

variable "image_id" {
  type        = string
  description = "ID образа для загрузки. Debian 12 по умолчанию"
  default     = "fd8e9t6fpgi13oh7q39f"
}

variable "preemptible" {
  type        = bool
  description = "Сделать машину прерываемой"
  default     = true
}

variable "ssh_user" {
  type        = string
  description = "Имя пользователя для SSH доступа"
  default     = "superuser"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Путь к публичному ключу для SSH доступа"
  default     = "~/.ssh/id_ed25519.pub"
}
