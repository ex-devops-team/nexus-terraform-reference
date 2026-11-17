# Модуль репозиториев ProductSpace

Создаёт hosted/group repositories и Nexus-роли для одного `productSpace`.

## Поддерживаемые форматы

- Docker;
- Maven;
- npm;
- Cargo;
- PyPI;
- Helm;
- Raw.

## Пример

```hcl
module "payments_repositories" {
  source = "git::https://github.com/ex-devops-team/nexus-terraform-reference.git//modules/productspace-repositories?ref=<commit-or-tag>"

  project = {
    name   = "payments"
    docker = true
    helm   = true
    mvn    = true
  }

  s3 = var.s3
}
```

До стабилизации контракта имя входного объекта остаётся `project` для
совместимости с перенесённым state. В целевой модели его значение —
`productSpace`.

## Модель доступа

- пользовательские группы не публикуют container images: это делает CI service
  account;
- nonprod packages могут публиковаться разработчиками согласно отдельной роли;
- release repositories используют `ALLOW_ONCE`, а удаление выполняется только
  администратором Nexus по заявке;
- роль аудитора инстанса создаётся вне этого модуля.

## Известные ограничения

- адаптировать `admin/rw/ro` privileges к групповой модели целевой организации;
- проверить cleanup: Docker dev — 7 дней по last download и 15 дней по upload,
  release — 180 дней; packages dev — 30, release — 365 дней;
- исключать Docker tag `stable` из ротации dev;
- подтвердить один blob store на `productSpace` и формат репозитория;
- добавить soft quota controller как отдельный компонент, не Terraform resource.
