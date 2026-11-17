# Внешние proxy repositories Nexus

Terraform root создаёт proxy repositories, format groups, blob stores и роли
чтения для публичных upstream. Имена строятся по схеме:

- `<format>-remote-<source>` — отдельный proxy;
- `<format>-remote` — group repository формата;
- `nx-read-<format>-remote` — роль чтения формата;
- `nx-read-all-remote` — агрегированная роль чтения.

## Поддерживаемые форматы

APT, Cargo, CocoaPods, Conan, Conda, Docker, Go, Gradle, Helm, Maven, npm,
NuGet, P2, PyPI, R, Raw, RubyGems, Terraform и YUM.

Список upstream задаётся в `variables.tf`. Публичные defaults являются
примером, а не организационным allowlist. Перед `apply` проверьте происхождение,
TLS, условия использования и доступность каждого URL.

## Требования

- Nexus Repository `>= 3.83.0`;
- Terraform CLI `>= 1.0.0`;
- provider `datadrivers/nexus` `3.0.0`;
- Nexus URL и credentials, переданные вне Git.

```bash
export NEXUS_URL='https://nexus.example.invalid/'
export NEXUS_USERNAME='<inject-from-secret-store>'
export NEXUS_PASSWORD='<inject-from-secret-store>'
```

По умолчанию provider проверяет TLS. Для одноразового локального PoC с
недоверенным сертификатом можно явно задать `TF_VAR_nexus_insecure=true`; для
общих и production-сред это значение должно оставаться `false`.

## Проверка и план

```bash
terraform -chdir=environments/nonprod-proxy init -backend=false -input=false
terraform -chdir=environments/nonprod-proxy validate
terraform -chdir=environments/nonprod-proxy plan -input=false -lock=false
```

Root не задаёт remote backend. Для командной работы добавьте backend в своём
consumer root или через отдельную организационную обвязку. Локальный state
допустим только для disposable PoC и не должен попадать в Git.

## S3 и cleanup policies

По умолчанию используются file blob stores (`s3.enabled=false`). Для S3
credentials передаются через secret store; endpoint, TLS, path style и
lifecycle проверяются на целевом S3-compatible сервисе.

`attach_cleanup_policies=false` является безопасным default. Включайте его
только после создания и readback всех ожидаемых `<format>-remote-policy-30d` в
целевом Nexus. Root ссылается на policies, но не создаёт их и не управляет
compact/GC tasks.

## Анонимный доступ

Для entries с `anonymous_access=true` Terraform формирует ограниченную роль
`nx-anonymous-custom` и настраивает встроенного пользователя `anonymous`.
Проверьте итоговые privileges перед применением: изменение анонимного доступа
затрагивает весь инстанс Nexus.

## Upstream authentication

Credentials закрытого upstream можно передать отдельной sensitive-переменной:

```hcl
helm_remote_proxy = {
  private-charts = {
    url = "https://charts.example.invalid"
  }
}

helm_remote_proxy_auth = {
  private-charts = {
    username = "service-user"
    password = "<inject-outside-git>"
  }
}
```

Ключ auth map обязан существовать в соответствующем proxy map. Не сохраняйте
credentials в `*.tfvars`, plan, state или shell history.

## Terraform provider mirror

Raw proxy `terraform-remote-yandex-providers` использует upstream, который уже
реализует HashiCorp Provider Network Mirror. Пример fail-closed CLI config:

```hcl
provider_installation {
  network_mirror {
    url     = "https://nexus.example.invalid/repository/terraform-remote-yandex-providers/"
    include = ["registry.terraform.io/*/*"]
  }

  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```

Произвольный Raw upstream не становится provider mirror автоматически. До
использования проверьте `index.json`, version metadata, archive URL и наличие
пакетов для архитектуры runner.

## Примеры клиентов

```bash
# Docker group
docker pull nexus.example.invalid/docker-remote/library/nginx:latest

# npm group
npm install --registry=https://nexus.example.invalid/repository/npm-remote/

# PyPI group
pip install --index-url=https://nexus.example.invalid/repository/pip-remote/simple requests

# Helm proxy
helm repo add prometheus https://nexus.example.invalid/repository/helm-remote-prometheus
```

`terraform apply` остаётся ручной операцией после review plan. Автоматический
apply и production credentials не входят в public reference.
