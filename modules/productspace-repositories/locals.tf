# Admin Roles
locals {
  docker_admin_roles = [
    # project docker group permissions
    "nx-repository-view-docker-docker-${var.project.name}-*",
    # project docker dev registry permissions
    "nx-repository-view-docker-docker-local-${var.project.name}-dev-*",
    # project docker prod registry permissions
    "nx-repository-view-docker-docker-local-${var.project.name}-prod-browse",
    "nx-repository-view-docker-docker-local-${var.project.name}-prod-edit",
    "nx-repository-view-docker-docker-local-${var.project.name}-prod-read",
  ]
  maven_admin_roles = [
    # project mvn group permissions
    "nx-repository-view-maven2-mvn-${var.project.name}-*",
    # project npm snapshots repository permissions
    "nx-repository-view-maven2-mvn-local-${var.project.name}-snapshots-*",
    # project npm releases repository permissions
    "nx-repository-view-maven2-mvn-local-${var.project.name}-releases-browse",
    "nx-repository-view-maven2-mvn-local-${var.project.name}-releases-edit",
    "nx-repository-view-maven2-mvn-local-${var.project.name}-releases-read",
  ]
  npm_admin_roles = [
    # project npm group permissions
    "nx-repository-view-npm-npm-${var.project.name}-*",
    # project npm registry permissions
    "nx-repository-view-npm-npm-local-${var.project.name}-browse",
    "nx-repository-view-npm-npm-local-${var.project.name}-edit",
    "nx-repository-view-npm-npm-local-${var.project.name}-read",
  ]
  cargo_admin_roles = [
    # project cargo group permissions
    "nx-repository-view-cargo-cargo-${var.project.name}-*",
    # project cargo registry permissions
    "nx-repository-view-cargo-cargo-local-${var.project.name}-browse",
    "nx-repository-view-cargo-cargo-local-${var.project.name}-edit",
    "nx-repository-view-cargo-cargo-local-${var.project.name}-read",
  ]
  helm_admin_roles = [
    # project helm registry permissions
    "nx-repository-view-helm-helm-local-${var.project.name}-browse",
    "nx-repository-view-helm-helm-local-${var.project.name}-edit",
    "nx-repository-view-helm-helm-local-${var.project.name}-read",
  ]
  pip_admin_roles = [
    # project pip permissions
    "nx-repository-view-pypi-pip-${var.project.name}-*",
    # project pip group permissions
    "nx-repository-view-pypi-pip-local-${var.project.name}-add",
    "nx-repository-view-pypi-pip-local-${var.project.name}-browse",
    "nx-repository-view-pypi-pip-local-${var.project.name}-edit",
    "nx-repository-view-pypi-pip-local-${var.project.name}-read",
  ]
  raw_admin_roles = [
    # project raw permissions
    "nx-repository-view-raw-raw-local-${var.project.name}-browse",
    "nx-repository-view-raw-raw-local-${var.project.name}-edit",
    "nx-repository-view-raw-raw-local-${var.project.name}-read",
  ]
}

# RW roles
locals {
  docker_rw_roles = [
    # project docker group permissions
    "nx-repository-view-docker-docker-${var.project.name}-*",
    # project docker dev registry permissions
    "nx-repository-view-docker-docker-local-${var.project.name}-dev-browse",
    "nx-repository-view-docker-docker-local-${var.project.name}-dev-edit",
    "nx-repository-view-docker-docker-local-${var.project.name}-dev-read",
    # project docker prod registry permissions
    "nx-repository-view-docker-docker-local-${var.project.name}-prod-browse",
    "nx-repository-view-docker-docker-local-${var.project.name}-prod-read",
  ]
  maven_rw_roles = [
    # project mvn group permissions
    "nx-repository-view-maven2-mvn-${var.project.name}-*",
    # project npm snapshots repository permissions
    "nx-repository-view-maven2-mvn-local-${var.project.name}-snapshots-*",
    # project npm releases repository permissions
    "nx-repository-view-maven2-mvn-local-${var.project.name}-releases-browse",
    "nx-repository-view-maven2-mvn-local-${var.project.name}-releases-read",
  ]
  npm_rw_roles = [
    # project npm group permissions
    "nx-repository-view-npm-npm-${var.project.name}-*",
    # project npm registry permissions
    "nx-repository-view-npm-npm-local-${var.project.name}-browse",
    "nx-repository-view-npm-npm-local-${var.project.name}-edit",
    "nx-repository-view-npm-npm-local-${var.project.name}-read",
  ]
  cargo_rw_roles = [
    # project cargo group permissions
    "nx-repository-view-cargo-cargo-${var.project.name}-*",
    # project cargo registry permissions
    "nx-repository-view-cargo-cargo-local-${var.project.name}-browse",
    "nx-repository-view-cargo-cargo-local-${var.project.name}-edit",
    "nx-repository-view-cargo-cargo-local-${var.project.name}-read",
  ]
  helm_rw_roles = [
    # project helm registry permissions
    "nx-repository-view-helm-helm-local-${var.project.name}-browse",
    "nx-repository-view-helm-helm-local-${var.project.name}-edit",
    "nx-repository-view-helm-helm-local-${var.project.name}-read",
  ]
  pip_rw_roles = [
    # project pip permissions
    "nx-repository-view-pypi-pip-${var.project.name}-*",
    # project pip group permissions
    "nx-repository-view-pypi-pip-local-${var.project.name}-add",
    "nx-repository-view-pypi-pip-local-${var.project.name}-browse",
    "nx-repository-view-pypi-pip-local-${var.project.name}-edit",
    "nx-repository-view-pypi-pip-local-${var.project.name}-read",
  ]
  raw_rw_roles = [
    # project raw permissions
    "nx-repository-view-raw-raw-local-${var.project.name}-browse",
    "nx-repository-view-raw-raw-local-${var.project.name}-edit",
    "nx-repository-view-raw-raw-local-${var.project.name}-read",
  ]
}

# RO roles
locals {
  docker_ro_roles = [
    # project docker group permissions
    "nx-repository-view-docker-docker-${var.project.name}-browse",
    # project docker dev registry permissions
    "nx-repository-view-docker-docker-local-${var.project.name}-dev-browse",
    "nx-repository-view-docker-docker-local-${var.project.name}-dev-read",
    # project docker prod registry permissions
    "nx-repository-view-docker-docker-local-${var.project.name}-prod-browse",
    "nx-repository-view-docker-docker-local-${var.project.name}-prod-read",
  ]
  maven_ro_roles = [
    # project mvn group permissions
    "nx-repository-view-maven2-mvn-${var.project.name}-browse",
    # project npm snapshots repository permissions
    "nx-repository-view-maven2-mvn-local-${var.project.name}-snapshots-browse",
    "nx-repository-view-maven2-mvn-local-${var.project.name}-snapshots-read",
    # project npm releases repository permissions
    "nx-repository-view-maven2-mvn-local-${var.project.name}-releases-browse",
    "nx-repository-view-maven2-mvn-local-${var.project.name}-releases-read",
  ]
  npm_ro_roles = [
    # project npm group permissions
    "nx-repository-view-npm-npm-${var.project.name}-browse",
    # project npm registry permissions
    "nx-repository-view-npm-npm-local-${var.project.name}-browse",
    "nx-repository-view-npm-npm-local-${var.project.name}-read",
  ]
  cargo_ro_roles = [
    # project cargo group permissions
    "nx-repository-view-cargo-cargo-${var.project.name}-browse",
    # project cargo registry permissions
    "nx-repository-view-cargo-cargo-local-${var.project.name}-browse",
    "nx-repository-view-cargo-cargo-local-${var.project.name}-read",
  ]
  helm_ro_roles = [
    # project helm registry permissions
    "nx-repository-view-helm-helm-local-${var.project.name}-browse",
    "nx-repository-view-helm-helm-local-${var.project.name}-read",
  ]
  pip_ro_roles = [
    # project pip permissions
    "nx-repository-view-pypi-pip-${var.project.name}-browse",
    # project pip group permissions
    "nx-repository-view-pypi-pip-local-${var.project.name}-browse",
    "nx-repository-view-pypi-pip-local-${var.project.name}-read",
  ]
  raw_ro_roles = [
    # project raw permissions
    "nx-repository-view-raw-raw-local-${var.project.name}-browse",
    "nx-repository-view-raw-raw-local-${var.project.name}-read",
  ]
}

# Upload permission
locals {
  upload_role = [
    "nx-component-upload"
  ]
}

# RO roles for extra repos
locals {
  docker_extra_clean = compact([for r in try(var.project.docker_extra_repos, []) : trimspace(r)])
  mvn_extra_clean    = compact([for r in try(var.project.mvn_extra_repos, []) : trimspace(r)])
  npm_extra_clean    = compact([for r in try(var.project.npm_extra_repos, []) : trimspace(r)])
  cargo_extra_clean  = compact([for r in try(var.project.cargo_extra_repos, []) : trimspace(r)])
  pip_extra_clean    = compact([for r in try(var.project.pip_extra_repos, []) : trimspace(r)])
}
locals {
  extra_repo_ro_privileges = distinct(compact(concat(
    var.project.docker ? flatten([for r in try(local.docker_extra_clean, []) : [
      "nx-repository-view-docker-${r}-browse"
    ]]) : [],

    var.project.mvn ? flatten([for r in try(local.mvn_extra_clean, []) : [
      "nx-repository-view-maven2-${r}-browse"
    ]]) : [],

    var.project.npm ? flatten([for r in try(local.npm_extra_clean, []) : [
      "nx-repository-view-npm-${r}-browse"
    ]]) : [],

    var.project.cargo ? flatten([for r in try(local.cargo_extra_clean, []) : [
      "nx-repository-view-cargo-${r}-browse"
    ]]) : [],

    var.project.pypi ? flatten([for r in try(local.pip_extra_clean, []) : [
      "nx-repository-view-pypi-${r}-browse"
    ]]) : [],

  )))

  extra_repo_rw_privileges = distinct(compact(concat(
    var.project.docker ? flatten([for r in try(local.docker_extra_clean, []) : [
      "nx-repository-view-docker-${r}-browse",
      "nx-repository-view-docker-${r}-read"
    ]]) : [],

    var.project.mvn ? flatten([for r in try(local.mvn_extra_clean, []) : [
      "nx-repository-view-maven2-${r}-browse",
      "nx-repository-view-maven2-${r}-read"
    ]]) : [],

    var.project.npm ? flatten([for r in try(local.npm_extra_clean, []) : [
      "nx-repository-view-npm-${r}-browse",
      "nx-repository-view-npm-${r}-read"
    ]]) : [],

    var.project.cargo ? flatten([for r in try(local.cargo_extra_clean, []) : [
      "nx-repository-view-cargo-${r}-browse",
      "nx-repository-view-cargo-${r}-read"
    ]]) : [],

    var.project.pypi ? flatten([for r in try(local.pip_extra_clean, []) : [
      "nx-repository-view-pypi-${r}-browse",
      "nx-repository-view-pypi-${r}-read"
    ]]) : [],

  )))

}

# SA rw roles
locals {
  docker_sa_roles = [
    # project docker group permissions
    "nx-repository-view-docker-docker-${var.project.name}-*",
    # project docker dev registry permissions
    "nx-repository-view-docker-docker-local-${var.project.name}-dev-*",
    # project docker prod registry permissions
    "nx-repository-view-docker-docker-local-${var.project.name}-prod-add",
    "nx-repository-view-docker-docker-local-${var.project.name}-prod-browse",
    "nx-repository-view-docker-docker-local-${var.project.name}-prod-edit",
    "nx-repository-view-docker-docker-local-${var.project.name}-prod-read"
  ]
  maven_sa_roles = [
    # project mvn group permissions
    "nx-repository-view-maven2-mvn-${var.project.name}-*",
    # project npm snapshots repository permissions
    "nx-repository-view-maven2-mvn-local-${var.project.name}-snapshots-*",
    # project npm releases repository permissions
    "nx-repository-view-maven2-mvn-local-${var.project.name}-releases-add",
    "nx-repository-view-maven2-mvn-local-${var.project.name}-releases-browse",
    "nx-repository-view-maven2-mvn-local-${var.project.name}-releases-edit",
    "nx-repository-view-maven2-mvn-local-${var.project.name}-releases-read"
  ]
  npm_sa_roles = [
    # project npm group permissions
    "nx-repository-view-npm-npm-${var.project.name}-*",
    # project npm registry permissions
    "nx-repository-view-npm-npm-local-${var.project.name}-add",
    "nx-repository-view-npm-npm-local-${var.project.name}-browse",
    "nx-repository-view-npm-npm-local-${var.project.name}-edit",
    "nx-repository-view-npm-npm-local-${var.project.name}-read"
  ]
  cargo_sa_roles = [
    # project cargo group permissions
    "nx-repository-view-cargo-cargo-${var.project.name}-*",
    # project cargo registry permissions
    "nx-repository-view-cargo-cargo-local-${var.project.name}-add",
    "nx-repository-view-cargo-cargo-local-${var.project.name}-browse",
    "nx-repository-view-cargo-cargo-local-${var.project.name}-edit",
    "nx-repository-view-cargo-cargo-local-${var.project.name}-read"
  ]
  helm_sa_roles = [
    # project helm registry permissions
    "nx-repository-view-helm-helm-local-${var.project.name}-add",
    "nx-repository-view-helm-helm-local-${var.project.name}-browse",
    "nx-repository-view-helm-helm-local-${var.project.name}-edit",
    "nx-repository-view-helm-helm-local-${var.project.name}-read",
  ]
  pip_sa_roles = [
    # project pip permissions
    "nx-repository-view-pypi-pip-${var.project.name}-*",
    # project pip group permissions
    "nx-repository-view-pypi-pip-local-${var.project.name}-add",
    "nx-repository-view-pypi-pip-local-${var.project.name}-browse",
    "nx-repository-view-pypi-pip-local-${var.project.name}-edit",
    "nx-repository-view-pypi-pip-local-${var.project.name}-read",
  ]
  raw_sa_roles = [
    # project raw permissions
    "nx-repository-view-raw-raw-local-${var.project.name}-add",
    "nx-repository-view-raw-raw-local-${var.project.name}-browse",
    "nx-repository-view-raw-raw-local-${var.project.name}-edit",
    "nx-repository-view-raw-raw-local-${var.project.name}-read",
  ]
}
