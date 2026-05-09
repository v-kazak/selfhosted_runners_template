# Self-Hosted GitLab Runner на базе Terraform + Ansible

Автоматизированное развертывание самохостинг GitLab Runner в Яндекс Cloud с использованием Terraform для инфраструктуры и Ansible для конфигурации.

## 📋 Требования

- Terraform >= 1.6
- Ansible >= 2.10
- Docker и Docker Compose установлены на машине, где будет запускаться `make terraform`
- Доступ к Яндекс Cloud (облако, каталог)
- GitLab инстанс с правами создавать токены runner

## 🚀 Быстрый старт

### 1. Подготовка Terraform переменных

Создайте файл `terraform/secret.auto.tfvars` с вашими учетными данными Яндекс Cloud:

```bash
# terraform/secret.auto.tfvars
token     = "your_yandex_cloud_oauth_token"
cloud_id  = "your_cloud_id"
folder_id = "your_folder_id"
```

**Где получить значения:**
- **token**: Яндекс Cloud → Управление профилем → API токены → Создать OAuth-токен
- **cloud_id**: Яндекс Cloud → Ваше облако → Общая информация → ID облака
- **folder_id**: Яндекс Cloud → Каталог → Общая информация → ID каталога

⚠️ **ВАЖНО:** Никогда не коммитьте `secret.auto.tfvars` в репозиторий!

### 2. Подготовка GitLab Runner конфигурации

Отредактируйте `ansible/roles/runners_install_and_run/tasks/main.yml` и заполните значения:

```yaml
- name: Register GitLab Runner
  community.docker.docker_container_exec:
    container: gitlab-runner
    command: >
          gitlab-runner register
          --non-interactive
          --url "https://gitlab.example.com"
          --token "glrt_your_runner_token_here"
          --executor "docker"
          --docker-image "alpine:latest"
          --description "ansible-managed-runner"
```

**Где получить значения:**
- **--url**: URL вашего GitLab инстанса (например, `https://gitlab.com` или ваш self-hosted)
- **--token**: Токен runner, полученный в GitLab:
  1. GitLab → Admin area → CI/CD → Runners → New instance runner
  2. Скопируйте токен после создания

### 3. Развертывание

```bash
# Инициализация Terraform и развертывание инфраструктуры
make terraform

# Или все вместе (Terraform + Ansible):
make start

# Просмотр статуса
make terraform

# Удаление инфраструктуры
make destroy
```

## 📂 Структура проекта

```
.
├── terraform/              # Terraform конфигурация
│   ├── main.tf            # Основные ресурсы (VPC, VM, NAT Gateway)
│   ├── variables.tf       # Переменные Terraform
│   ├── local.tf           # Локальные переменные
│   ├── output.tf          # Outputs (IP адреса, SSH команда)
│   └── secret.auto.tfvars # ⚠️ СОЗДАТЬ ВРУЧНУЮ (в .gitignore)
│
├── ansible/               # Ansible конфигурация
│   ├── playbook.yml       # Основной playbook
│   ├── ansible.cfg        # Конфиг Ansible
│   ├── inventory.ini      # Генерируется Terraform
│   └── roles/
│       ├── install_docker/
│       └── runners_install_and_run/
│
├── Makefile               # Команды для автоматизации
└── README.md              # Эта документация
```

## 🔧 Переменные Terraform

По умолчанию развертывается:
- **VM count**: 1 машина
- **vCPU**: 2 ядра
- **RAM**: 2 ГБ
- **Disk**: 15 ГБ (network-hdd)
- **Image**: Debian 12
- **Preemptible**: true (сэкономит деньги)
- **NAT Gateway**: Для исходящего интернета без публичного IP

Все параметры можно переопределить через переменные:

```bash
# Например, 3 машины с 4 ядрами:
terraform -chdir=terraform apply -var="vps_count=3" -var="cores_count=4"
```

## 🌐 Сетевая архитектура

- **NAT Gateway**: Машины получают исходящий интернет через NAT Gateway (без публичного IP)
- **Приватная сеть**: 10.10.0.0/24
- **Security Group**: Разрешены SSH (22), HTTP (80), HTTPS (443) с 0.0.0.0/0

**SSH подключение:**
- Если VM имеет публичный IP: `ssh superuser@<PUBLIC_IP>`
- Без публичного IP: Требуется Bastion или VPN

## 📝 Outputs после развертывания

После `make terraform` вы увидите:

```
====================================================
 Terraform Apply Summary
----------------------------------------------------
 VM count     : 1
 SSH user     : superuser
 Zone         : ru-central1-d

 Addresses:
   - 192.168.1.10

 Quick SSH:
   ssh superuser@192.168.1.10
====================================================
```

## ⚙️ Ansible конфигурация

Playbook выполняет:
1. Ожидание SSH доступности (таймаут 5 минут)
2. Установка Docker
3. Запуск GitLab Runner контейнера
4. Регистрация runner в вашем GitLab инстансе

## 🔐 Безопасность

- Токены хранятся в `secret.auto.tfvars` (**не коммитить!**)
- GitLab runner токены передаются только при инициализации
- SSH ключи генерируются через cloud-init и не хранятся в Terraform state
- NAT Gateway обеспечивает приватные IP для машин

## 🐛 Troubleshooting

### Ошибка: "Количество статических публичных IP-адресов 1 / 1"
- NAT Gateway не требует публичного IP. Проверьте `nat = false` в variables.tf
- Если нужен публичный IP: `terraform apply -var="nat=true"`

### SSH таймаут при подключении к VM
- Если VM без публичного IP, используйте приватный адрес из inventory.ini
- Проверьте Security Group правила в Яндекс Cloud

### GitLab Runner не регистрируется
- Проверьте правильность `--url` и `--token` в ansible playbook
- Убедитесь, что URL доступен из сети VM
- Логи: `docker exec gitlab-runner gitlab-runner --debug run`

## 📖 Дополнительно

- [Yandex Cloud Terraform Provider](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs)
- [GitLab Runner Documentation](https://docs.gitlab.com/runner/)
- [Ansible Community Docker Module](https://docs.ansible.com/ansible/latest/collections/community/docker/)

## 📄 Лицензия

MIT
