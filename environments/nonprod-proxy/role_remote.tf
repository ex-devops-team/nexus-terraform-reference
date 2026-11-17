locals {
  anonymous_apt_privilege_names = flatten([
    for key, list_value in var.apt_remote_proxy :
    [
      "nx-repository-view-apt-apt-remote-${key}-browse",
      "nx-repository-view-apt-apt-remote-${key}-read"
    ]
    if try(list_value.anonymous_access, false)
  ])

  anonymous_cargo_privilege_names = flatten([
    for key, list_value in var.cargo_remote_proxy :
    [
      "nx-repository-view-cargo-cargo-remote-${key}-browse",
      "nx-repository-view-cargo-cargo-remote-${key}-read"
    ]
    if try(list_value.anonymous_access, false)
  ])

  anonymous_cocoapods_privilege_names = flatten([
    for key, list_value in var.cocoapods_remote_proxy :
    [
      "nx-repository-view-cocoapods-cocoapods-remote-${key}-browse",
      "nx-repository-view-cocoapods-cocoapods-remote-${key}-read"
    ]
    if try(list_value.anonymous_access, false)
  ])

  anonymous_conan_privilege_names = flatten([
    for key, list_value in var.conan_remote_proxy :
    [
      "nx-repository-view-conan-conan-remote-${key}-browse",
      "nx-repository-view-conan-conan-remote-${key}-read"
    ]
    if try(list_value.anonymous_access, false)
  ])

  anonymous_conda_privilege_names = flatten([
    for key, list_value in var.conda_remote_proxy :
    [
      "nx-repository-view-conda-conda-remote-${key}-browse",
      "nx-repository-view-conda-conda-remote-${key}-read"
    ]
    if try(list_value.anonymous_access, false)
  ])

  anonymous_docker_privilege_names = flatten([
    for key, list_value in var.docker_remote_proxy :
    [
      "nx-repository-view-docker-docker-remote-${key}-browse",
      "nx-repository-view-docker-docker-remote-${key}-read"
    ]
    if try(list_value.anonymous_access, false)
  ])

  anonymous_go_privilege_names = flatten([
    for key, list_value in var.go_remote_proxy :
    [
      "nx-repository-view-go-go-remote-${key}-browse",
      "nx-repository-view-go-go-remote-${key}-read"
    ]
    if try(list_value.anonymous_access, false)
  ])

  anonymous_gradle_privilege_names = flatten([
    for key, list_value in var.gradle_remote_proxy :
    [
      "nx-repository-view-maven2-gradle-remote-${key}-browse",
      "nx-repository-view-maven2-gradle-remote-${key}-read"
    ]
    if try(list_value.anonymous_access, false)
  ])

  anonymous_helm_privilege_names = flatten([
    for key, list_value in var.helm_remote_proxy :
    [
      "nx-repository-view-helm-helm-remote-${key}-browse",
      "nx-repository-view-helm-helm-remote-${key}-read"
    ]
    if try(list_value.anonymous_access, false)
  ])

  anonymous_mvn_privilege_names = flatten([
    for key, list_value in var.mvn_remote_proxy :
    [
      "nx-repository-view-maven2-mvn-remote-${key}-browse",
      "nx-repository-view-maven2-mvn-remote-${key}-read"
    ]
    if try(list_value.anonymous_access, false)
  ])

  anonymous_npm_privilege_names = flatten([
    for key, list_value in var.npm_remote_proxy :
    [
      "nx-repository-view-npm-npm-remote-${key}-browse",
      "nx-repository-view-npm-npm-remote-${key}-read"
    ]
    if try(list_value.anonymous_access, false)
  ])

  anonymous_nuget_privilege_names = flatten([
    for key, list_value in var.nuget_remote_proxy :
    [
      "nx-repository-view-nuget-nuget-remote-${key}-browse",
      "nx-repository-view-nuget-nuget-remote-${key}-read"
    ]
    if try(list_value.anonymous_access, false)
  ])

  anonymous_p2_privilege_names = flatten([
    for key, list_value in var.p2_remote_proxy :
    [
      "nx-repository-view-p2-p2-remote-${key}-browse",
      "nx-repository-view-p2-p2-remote-${key}-read"
    ]
    if try(list_value.anonymous_access, false)
  ])

  anonymous_pip_privilege_names = flatten([
    for key, list_value in var.pip_remote_proxy :
    [
      "nx-repository-view-pypi-pip-remote-${key}-browse",
      "nx-repository-view-pypi-pip-remote-${key}-read"
    ]
    if try(list_value.anonymous_access, false)
  ])

  anonymous_raw_privilege_names = flatten([
    for key, list_value in var.raw_remote_proxy :
    [
      "nx-repository-view-raw-raw-remote-${key}-browse",
      "nx-repository-view-raw-raw-remote-${key}-read"
    ]
    if try(list_value.anonymous_access, false)
  ])

  anonymous_r_privilege_names = flatten([
    for key, list_value in var.r_remote_proxy :
    [
      "nx-repository-view-r-r-remote-${key}-browse",
      "nx-repository-view-r-r-remote-${key}-read"
    ]
    if try(list_value.anonymous_access, false)
  ])

  anonymous_rubygems_privilege_names = flatten([
    for key, list_value in var.rubygems_remote_proxy :
    [
      "nx-repository-view-rubygems-rubygems-remote-${key}-browse",
      "nx-repository-view-rubygems-rubygems-remote-${key}-read"
    ]
    if try(list_value.anonymous_access, false)
  ])

  anonymous_terraform_privilege_names = flatten([
    for key, list_value in var.terraform_remote_proxy :
    [
      "nx-repository-view-raw-terraform-remote-${key}-browse",
      "nx-repository-view-raw-terraform-remote-${key}-read"
    ]
    if try(list_value.anonymous_access, false)
  ])

  anonymous_yum_privilege_names = flatten([
    for key, list_value in var.yum_remote_proxy :
    [
      "nx-repository-view-yum-yum-remote-${key}-browse",
      "nx-repository-view-yum-yum-remote-${key}-read"
    ]
    if try(list_value.anonymous_access, false)
  ])

  anonymous_group_privilege_names = compact([
    length(local.anonymous_docker_privilege_names) > 0 ? "nx-repository-view-docker-docker-remote-*" : "",
    length(local.anonymous_cargo_privilege_names) > 0 ? "nx-repository-view-cargo-cargo-remote-*" : "",
    length(local.anonymous_go_privilege_names) > 0 ? "nx-repository-view-go-go-remote-*" : "",
    length(local.anonymous_mvn_privilege_names) > 0 ? "nx-repository-view-maven2-mvn-remote-*" : "",
    length(local.anonymous_npm_privilege_names) > 0 ? "nx-repository-view-npm-npm-remote-*" : "",
    length(local.anonymous_nuget_privilege_names) > 0 ? "nx-repository-view-nuget-nuget-remote-*" : "",
    length(local.anonymous_pip_privilege_names) > 0 ? "nx-repository-view-pypi-pip-remote-*" : "",
    length(local.anonymous_r_privilege_names) > 0 ? "nx-repository-view-r-r-remote-*" : "",
    length(local.anonymous_rubygems_privilege_names) > 0 ? "nx-repository-view-rubygems-rubygems-remote-*" : "",
    length(local.anonymous_yum_privilege_names) > 0 ? "nx-repository-view-yum-yum-remote-*" : ""
  ])
}

resource "nexus_security_role" "read_all" {
  description = "read all remote repositories role"
  name        = "nx-read-all-remote"
  # add nx-repository-view-[tool]-[tool]-remote-* only when group exist
  privileges = [
    "nx-healthcheck-read",
    "nx-repository-view-cargo-cargo-remote-*",
    "nx-repository-view-docker-docker-login-read",
    "nx-repository-view-docker-docker-remote-*",
    "nx-repository-view-go-go-remote-*",
    "nx-repository-view-maven2-mvn-remote-*",
    "nx-repository-view-nuget-nuget-remote-*",
    "nx-repository-view-pypi-pip-remote-*",
    "nx-repository-view-r-r-remote-*",
    "nx-repository-view-rubygems-rubygems-remote-*",
    "nx-search-read"
  ]
  roles = [
    nexus_security_role.apt_proxy_role.id,
    nexus_security_role.cargo_proxy_role.id,
    nexus_security_role.cocoapods_proxy_role.id,
    nexus_security_role.conan_proxy_role.id,
    nexus_security_role.conda_proxy_role.id,
    nexus_security_role.docker_proxy_role.id,
    nexus_security_role.go_proxy_role.id,
    nexus_security_role.gradle_proxy_role.id,
    nexus_security_role.helm_proxy_role.id,
    nexus_security_role.mvn_proxy_role.id,
    nexus_security_role.npm_proxy_role.id,
    nexus_security_role.nuget_proxy_role.id,
    nexus_security_role.p2_proxy_role.id,
    nexus_security_role.pip_proxy_role.id,
    nexus_security_role.raw_proxy_role.id,
    nexus_security_role.r_proxy_role.id,
    nexus_security_role.rubygems_proxy_role.id,
    nexus_security_role.terraform_proxy_role.id,
    nexus_security_role.yum_proxy_role.id
  ]
  roleid = "nx-read-all-remote"
  depends_on = [
    nexus_security_role.apt_proxy_role,
    nexus_security_role.cargo_proxy_role,
    nexus_security_role.cocoapods_proxy_role,
    nexus_security_role.conan_proxy_role,
    nexus_security_role.conda_proxy_role,
    nexus_security_role.docker_proxy_role,
    nexus_security_role.go_proxy_role,
    nexus_security_role.gradle_proxy_role,
    nexus_security_role.helm_proxy_role,
    nexus_security_role.mvn_proxy_role,
    nexus_security_role.npm_proxy_role,
    nexus_security_role.nuget_proxy_role,
    nexus_security_role.p2_proxy_role,
    nexus_security_role.pip_proxy_role,
    nexus_security_role.raw_proxy_role,
    nexus_security_role.r_proxy_role,
    nexus_security_role.rubygems_proxy_role,
    nexus_security_role.terraform_proxy_role,
    nexus_security_role.yum_proxy_role,
    nexus_repository_docker_hosted.docker_login
  ]
}

resource "nexus_security_role" "auditor" {
  description = "Audit nexus configuration role"
  name        = "nx-auditor"
  privileges = [
    "nx-blobstores-read",
    "nx-bundles-read",
    "nx-capabilities-read",
    "nx-datastores-read",
    "nx-healthcheck-read",
    "nx-healthcheck-summary-read",
    "nx-iq-violation-summary-read",
    "nx-ldap-read",
    "nx-licensing-read",
    "nx-logging-read",
    "nx-privileges-read",
    "nx-repository-admin-*-*-browse",
    "nx-repository-admin-*-*-read",
    "nx-repository-view-*-*-browse",
    "nx-roles-read",
    "nx-script-*-read",
    "nx-search-read",
    "nx-selectors-read",
    "nx-settings-read",
    "nx-ssl-truststore-read",
    "nx-tasks-read",
    "nx-users-read",
  ]
  roleid = "nx-auditor"

}

resource "nexus_security_role" "proxyfirewall" {
  description = "Proxy Firewall nexus role"
  name        = "nx-proxyfirewall"
  privileges = [
    "nx-repository-view-*-*-read",
    "nx-repository-view-*-*-browse"
  ]
  roleid = "nx-proxyfirewall"

}

resource "nexus_security_role" "monitoring" {
  description = "Nexus monitoring role"
  name        = "nx-monitoring"
  privileges = [
    "nx-metrics-all"
  ]
  roleid = "nx-monitoring"

}

resource "nexus_security_role" "anonymous" {
  description = "Nexus anonymous custom role"
  name        = "nx-anonymous-custom"
  privileges = concat(
    [
      "nx-search-read",
    ],
    local.anonymous_apt_privilege_names,
    local.anonymous_cargo_privilege_names,
    local.anonymous_cocoapods_privilege_names,
    local.anonymous_conan_privilege_names,
    local.anonymous_conda_privilege_names,
    local.anonymous_docker_privilege_names,
    local.anonymous_go_privilege_names,
    local.anonymous_gradle_privilege_names,
    local.anonymous_helm_privilege_names,
    local.anonymous_mvn_privilege_names,
    local.anonymous_npm_privilege_names,
    local.anonymous_nuget_privilege_names,
    local.anonymous_p2_privilege_names,
    local.anonymous_pip_privilege_names,
    local.anonymous_raw_privilege_names,
    local.anonymous_r_privilege_names,
    local.anonymous_rubygems_privilege_names,
    local.anonymous_terraform_privilege_names,
    local.anonymous_yum_privilege_names,
    local.anonymous_group_privilege_names
  )
  roleid = "nx-anonymous-custom"
  depends_on = [
    nexus_security_role.apt_proxy_role,
    nexus_security_role.cargo_proxy_role,
    nexus_security_role.cocoapods_proxy_role,
    nexus_security_role.conan_proxy_role,
    nexus_security_role.conda_proxy_role,
    nexus_security_role.docker_proxy_role,
    nexus_security_role.go_proxy_role,
    nexus_security_role.gradle_proxy_role,
    nexus_security_role.helm_proxy_role,
    nexus_security_role.mvn_proxy_role,
    nexus_security_role.npm_proxy_role,
    nexus_security_role.nuget_proxy_role,
    nexus_security_role.p2_proxy_role,
    nexus_security_role.pip_proxy_role,
    nexus_security_role.raw_proxy_role,
    nexus_security_role.r_proxy_role,
    nexus_security_role.rubygems_proxy_role,
    nexus_security_role.terraform_proxy_role,
    nexus_security_role.yum_proxy_role,
    nexus_repository_docker_hosted.docker_login
  ]

}
