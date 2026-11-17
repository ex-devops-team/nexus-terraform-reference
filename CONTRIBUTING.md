# Участие в разработке

1. Создайте Issue с описанием проблемы и границы изменения.
2. Подготовьте отдельную ветку и Pull Request.
3. Не добавляйте credentials, state, plan-файлы и внутренние identifiers.
4. Запустите локальные проверки:

   ```bash
   terraform fmt -check -recursive
   scripts/validate_iac.sh all
   pre-commit run --all-files
   ```

5. В PR укажите проверенный Nexus/provider baseline и границу evidence.

Изменение upstream defaults требует отдельного обоснования происхождения и
доступности URL. Изменение security gates требует review владельцев.
