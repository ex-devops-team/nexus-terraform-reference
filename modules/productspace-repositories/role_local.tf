resource "nexus_security_role" "project_admins_role" {
  description = "Role for ${var.project.name}-admin group"
  name        = "${var.project.name}-admins-role"
  roleid      = "${var.project.name}-admin"
  privileges = concat(
    var.project.docker ? local.docker_admin_roles : [],
    var.project.cargo ? local.cargo_admin_roles : [],
    var.project.helm ? local.helm_admin_roles : [],
    var.project.mvn ? local.maven_admin_roles : [],
    var.project.npm ? local.npm_admin_roles : [],
    var.project.pypi ? local.pip_admin_roles : [],
    var.project.raw ? local.raw_admin_roles : [],
    local.extra_repo_ro_privileges,
    local.upload_role
  )
  depends_on = [
    nexus_repository_docker_group.docker_local_project_group,
    nexus_repository_docker_hosted.docker_local_project_dev,
    nexus_repository_docker_hosted.docker_local_project_prod,
    nexus_repository_cargo_group.cargo_local_project_group,
    nexus_repository_cargo_hosted.cargo_local_project,
    nexus_repository_helm_hosted.helm_local_project,
    nexus_repository_maven_group.maven_local_project_group,
    nexus_repository_maven_hosted.maven_local_project_releases,
    nexus_repository_maven_hosted.maven_local_project_snapshots,
    nexus_repository_npm_group.npm_local_project_group,
    nexus_repository_npm_hosted.npm_local_project,
    nexus_repository_pypi_group.pypi_local_project_group,
    nexus_repository_pypi_hosted.pypi_local_project,
    nexus_repository_raw_hosted.raw_local_project
  ]
}

resource "nexus_security_role" "project_rw_role" {
  description = "Role for ${var.project.name}-rw group"
  name        = "${var.project.name}-rw-role"
  roleid      = "${var.project.name}-rw"
  privileges = concat(
    var.project.docker ? local.docker_rw_roles : [],
    var.project.cargo ? local.cargo_rw_roles : [],
    var.project.helm ? local.helm_rw_roles : [],
    var.project.mvn ? local.maven_rw_roles : [],
    var.project.npm ? local.npm_rw_roles : [],
    var.project.pypi ? local.pip_rw_roles : [],
    var.project.raw ? local.raw_rw_roles : [],
    local.extra_repo_rw_privileges,
    local.upload_role
  )
  depends_on = [
    nexus_repository_docker_group.docker_local_project_group,
    nexus_repository_docker_hosted.docker_local_project_dev,
    nexus_repository_docker_hosted.docker_local_project_prod,
    nexus_repository_cargo_group.cargo_local_project_group,
    nexus_repository_cargo_hosted.cargo_local_project,
    nexus_repository_helm_hosted.helm_local_project,
    nexus_repository_maven_group.maven_local_project_group,
    nexus_repository_maven_hosted.maven_local_project_releases,
    nexus_repository_maven_hosted.maven_local_project_snapshots,
    nexus_repository_npm_group.npm_local_project_group,
    nexus_repository_npm_hosted.npm_local_project,
    nexus_repository_pypi_group.pypi_local_project_group,
    nexus_repository_pypi_hosted.pypi_local_project,
    nexus_repository_raw_hosted.raw_local_project
  ]
}

resource "nexus_security_role" "project_ro_role" {
  description = "Role for ${var.project.name}-ro group"
  name        = "${var.project.name}-ro-role"
  roleid      = "${var.project.name}-ro"
  privileges = concat(
    var.project.docker ? local.docker_ro_roles : [],
    var.project.cargo ? local.cargo_ro_roles : [],
    var.project.helm ? local.helm_ro_roles : [],
    var.project.mvn ? local.maven_ro_roles : [],
    var.project.npm ? local.npm_ro_roles : [],
    var.project.pypi ? local.pip_ro_roles : [],
    var.project.raw ? local.raw_ro_roles : [],
    local.extra_repo_ro_privileges
  )
  depends_on = [
    nexus_repository_docker_group.docker_local_project_group,
    nexus_repository_docker_hosted.docker_local_project_dev,
    nexus_repository_docker_hosted.docker_local_project_prod,
    nexus_repository_cargo_group.cargo_local_project_group,
    nexus_repository_cargo_hosted.cargo_local_project,
    nexus_repository_helm_hosted.helm_local_project,
    nexus_repository_maven_group.maven_local_project_group,
    nexus_repository_maven_hosted.maven_local_project_releases,
    nexus_repository_maven_hosted.maven_local_project_snapshots,
    nexus_repository_npm_group.npm_local_project_group,
    nexus_repository_npm_hosted.npm_local_project,
    nexus_repository_pypi_group.pypi_local_project_group,
    nexus_repository_pypi_hosted.pypi_local_project,
    nexus_repository_raw_hosted.raw_local_project
  ]
}

resource "nexus_security_role" "project_sa_role" {
  description = "Service Account Role for ${var.project.name} project"
  name        = "sa-${var.project.name}"
  privileges = concat(
    var.project.docker ? local.docker_sa_roles : [],
    var.project.cargo ? local.cargo_sa_roles : [],
    var.project.helm ? local.helm_sa_roles : [],
    var.project.mvn ? local.maven_sa_roles : [],
    var.project.npm ? local.npm_sa_roles : [],
    var.project.pypi ? local.pip_sa_roles : [],
    var.project.raw ? local.raw_sa_roles : [],
    local.extra_repo_ro_privileges
  )
  roleid = "sa-${var.project.name}"
  depends_on = [
    nexus_repository_docker_group.docker_local_project_group,
    nexus_repository_docker_hosted.docker_local_project_dev,
    nexus_repository_docker_hosted.docker_local_project_prod,
    nexus_repository_cargo_group.cargo_local_project_group,
    nexus_repository_cargo_hosted.cargo_local_project,
    nexus_repository_helm_hosted.helm_local_project,
    nexus_repository_maven_group.maven_local_project_group,
    nexus_repository_maven_hosted.maven_local_project_releases,
    nexus_repository_maven_hosted.maven_local_project_snapshots,
    nexus_repository_npm_group.npm_local_project_group,
    nexus_repository_npm_hosted.npm_local_project,
    nexus_repository_pypi_group.pypi_local_project_group,
    nexus_repository_pypi_hosted.pypi_local_project,
    nexus_repository_raw_hosted.raw_local_project
  ]
}
