# Terraform reference для Nexus Repository

Публичный пример управления Nexus Repository через Terraform. Репозиторий
создан без истории и данных внутреннего проекта и предназначен для изучения,
локальных PoC и повторного использования отдельных модулей.

## Область поддержки

- `environments/nonprod-proxy` — пример proxy repositories, групп и read-only
  ролей для публичных upstream;
- `modules/productspace-repositories` — переиспользуемый модуль hosted/group
  repositories и ролей одного ProductSpace;
- [`.terraformrc.example`](.terraformrc.example) — fail-closed пример provider
  mirror через Nexus;
- [`docs/architecture.md`](docs/architecture.md) — границы и схема решения.

В публичную область намеренно не входят production pull-mirror, customer RBAC,
корпоративные адреса, credentials, Terraform state, внутренние pipelines и
операционные evidence. Этот репозиторий не является готовой production
конфигурацией: параметры доступа, cleanup, S3 и сетевые политики необходимо
проверить в своей среде.

## Publication review

Публикация подготовлена как clean-room snapshot без Git history приватного
проекта. Из defaults удалены закрытые и контекстно-специфичные endpoints.
Оставшиеся адреса являются публичными upstream
репозиториями производителей или open-source проектов; они не означают
обязательного включения продукта в конкретную платформу. Перед повторным
использованием выполните собственный legal/security review.

## Совместимость

Исходный baseline проверялся с Nexus Repository `3.96.4`, Terraform CLI
`1.13.5` и `datadrivers/nexus` `3.0.0`. CI публичного репозитория проверяет
форматирование, `terraform validate`, TFLint, Trivy и отсутствие секретов.

## Быстрый старт

```bash
export NEXUS_URL='https://nexus.example.invalid/'
export NEXUS_USERNAME='<inject-outside-git>'
export NEXUS_PASSWORD='<inject-outside-git>'

terraform -chdir=environments/nonprod-proxy init -backend=false
terraform -chdir=environments/nonprod-proxy validate
terraform -chdir=environments/nonprod-proxy plan
```

Пример не выполняет `apply` автоматически. Перед применением проверьте plan,
upstream URLs, модель анонимного доступа, cleanup policies и место хранения
state.

## Статус сопровождения

Статус: **экспериментальный reference**. Изменения принимаются через Issue и
Pull Request. Об уязвимостях сообщайте по правилам из
[`SECURITY.md`](SECURITY.md).

## Лицензия

[Apache License 2.0](LICENSE).
