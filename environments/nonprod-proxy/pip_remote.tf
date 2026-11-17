locals {
  pip_member_names = flatten([
    for key, list_value in var.pip_remote_proxy : "pip-remote-${key}"
  ])

  pip_privilege_names = flatten([
    for key, list_value in var.pip_remote_proxy : "nx-repository-view-pypi-pip-remote-${key}-*"
  ])

  pip_blobstore_depenecies = var.s3["enabled"] ? nexus_blobstore_s3.pip_remote_blobstore_s3 : nexus_blobstore_file.pip_remote_blobstore

  pip_proxy_auth = {
    for key, value in var.pip_remote_proxy : key => {
      type     = try(value.auth.type, try(var.pip_remote_proxy_auth[key].type, "username"))
      username = trimspace(try(value.auth.username, try(var.pip_remote_proxy_auth[key].username, "")))
      password = trimspace(try(value.auth.password, try(var.pip_remote_proxy_auth[key].password, "")))
    }
  }
}

resource "nexus_blobstore_s3" "pip_remote_blobstore_s3" {
  name = "pip-remote"
  bucket_configuration {
    bucket {
      name       = "pip-remote"
      region     = var.s3["region"]
      expiration = var.s3["expiration"]
    }
    advanced_bucket_connection {
      endpoint         = var.s3["url"]
      force_path_style = var.s3["path_style"]
    }
    bucket_security {
      access_key_id     = var.s3["access_key"]
      secret_access_key = var.s3["secret_key"]
    }
  }
  count = var.s3["enabled"] ? 1 : 0

}

resource "nexus_blobstore_file" "pip_remote_blobstore" {
  name  = "pip-remote"
  path  = "pip-remote"
  count = var.s3["enabled"] ? 0 : 1
}

resource "nexus_repository_pypi_proxy" "pip_proxy" {
  for_each = var.pip_remote_proxy

  name   = "pip-remote-${each.key}"
  online = true

  storage {
    blob_store_name                = "pip-remote"
    strict_content_type_validation = true
  }

  dynamic "cleanup" {
    for_each = var.attach_cleanup_policies ? [1] : []

    content {
      policy_names = ["pip-remote-policy-30d"]
    }
  }

  proxy {
    remote_url       = each.value.url
    content_max_age  = 1440
    metadata_max_age = 1440
  }

  negative_cache {
    enabled = true
    ttl     = 1440
  }

  http_client {
    blocked    = false
    auto_block = true

    dynamic "authentication" {
      for_each = local.pip_proxy_auth[each.key].username != "" && local.pip_proxy_auth[each.key].password != "" ? [local.pip_proxy_auth[each.key]] : []
      content {
        type     = authentication.value.type
        username = authentication.value.username
        password = authentication.value.password
      }
    }
  }

  depends_on = [
    local.pip_blobstore_depenecies
  ]
}

resource "nexus_repository_pypi_group" "pypi_remote_group" {

  name   = "pip-remote"
  online = true

  group {
    member_names = local.pip_member_names
  }

  storage {
    blob_store_name                = "pip-remote"
    strict_content_type_validation = true
  }

  depends_on = [
    local.pip_blobstore_depenecies,
    nexus_repository_pypi_proxy.pip_proxy
  ]
}

resource "nexus_security_role" "pip_proxy_role" {
  description = "pip read all proxy repositories"
  name        = "nx-read-pip-remote"
  privileges  = local.pip_privilege_names
  roleid      = "nx-read-pip-remote"

  depends_on = [
    nexus_repository_pypi_proxy.pip_proxy
  ]
}
