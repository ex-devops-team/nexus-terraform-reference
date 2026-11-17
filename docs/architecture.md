# Архитектура public reference

## Граница решения

```mermaid
flowchart LR
    Operator[Platform engineer] -->|reviewed plan/apply| TF[Terraform]
    TF -->|Nexus REST API| Nexus[Nexus Repository]
    Nexus --> Proxy[Proxy repositories]
    Proxy --> Upstream[Public upstream repositories]
    Nexus --> Hosted[ProductSpace hosted repositories]
    Nexus --> Groups[ProductSpace group repositories]
    Nexus --> RBAC[Roles and privileges]
    Hosted --> Storage[(File or S3 blob store)]
    Groups --> Hosted
```

`environments/nonprod-proxy` создаёт общие proxy repositories и read roles.
`modules/productspace-repositories` создаёт tenant-specific hosted/group
repositories и роли. State, credentials, production topology и lifecycle
cleanup policies находятся за границей public reference.

## Trust boundary

- upstream URL является входом доверия и должен проходить отдельный review;
- credentials передаются через secret store или защищённые переменные среды;
- `plan` является обязательным проверяемым артефактом перед ручным `apply`;
- публичные defaults служат примером, а не организационным allowlist;
- anonymous access включается только для явно отмеченных repositories.

## Что проверяет CI

- Terraform formatting и validation;
- TFLint для обоих root/module scopes;
- Trivy configuration scan;
- Gitleaks и базовые pre-commit проверки.

CI не подтверждает доступность upstream, корректность production RBAC, S3
совместимость или безопасное восстановление state — эти проверки выполняются в
целевой среде.
