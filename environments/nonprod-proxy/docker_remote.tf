# Compatibility floor: Nexus Repository 3.83.0. Every Docker repository in
# this root enables path_based_routing, which older Nexus APIs do not support.
locals {
  docker_member_names = flatten([
    for key, list_value in var.docker_remote_proxy : "docker-remote-${key}"
  ])

  docker_privilege_names = flatten([
    for key, list_value in var.docker_remote_proxy : "nx-repository-view-docker-docker-remote-${key}-*"
  ])

  docker_proxy_auth = {
    for key, value in var.docker_remote_proxy : key => {
      type     = try(value.auth.type, try(var.docker_remote_proxy_auth[key].type, "username"))
      username = trimspace(try(value.auth.username, try(var.docker_remote_proxy_auth[key].username, "")))
      password = trimspace(try(value.auth.password, try(var.docker_remote_proxy_auth[key].password, "")))
    }
  }

  docker_blobstore_depenecies = var.s3["enabled"] ? nexus_blobstore_s3.docker_remote_blobstore_s3 : nexus_blobstore_file.docker_remote_blobstore
}

resource "nexus_blobstore_s3" "docker_remote_blobstore_s3" {
  name = "docker-remote"
  bucket_configuration {
    bucket {
      name       = "docker-remote"
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
resource "nexus_blobstore_file" "docker_remote_blobstore" {
  name  = "docker-remote"
  path  = "docker-remote"
  count = var.s3["enabled"] ? 0 : 1
}

resource "nexus_repository_docker_hosted" "docker_login" {
  name   = "docker-login"
  online = true

  docker {
    force_basic_auth   = false
    path_based_routing = true
    v1_enabled         = false
  }

  storage {
    blob_store_name                = "docker-remote"
    strict_content_type_validation = true
    write_policy                   = "ALLOW"
  }

  dynamic "cleanup" {
    for_each = var.attach_cleanup_policies ? [1] : []

    content {
      policy_names = ["docker-remote-policy-30d"]
    }
  }

  component {
    proprietary_components = true
  }

  depends_on = [
    local.docker_blobstore_depenecies
  ]
}

resource "nexus_repository_docker_proxy" "docker_proxy" {
  for_each = var.docker_remote_proxy

  name   = "docker-remote-${each.key}"
  online = true

  docker {
    force_basic_auth   = false
    path_based_routing = true
    v1_enabled         = false
  }

  docker_proxy {
    index_type = each.value.index
  }

  storage {
    blob_store_name                = "docker-remote"
    strict_content_type_validation = true
  }

  dynamic "cleanup" {
    for_each = var.attach_cleanup_policies ? [1] : []

    content {
      policy_names = ["docker-remote-policy-30d"]
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
      for_each = local.docker_proxy_auth[each.key].username != "" && local.docker_proxy_auth[each.key].password != "" ? [local.docker_proxy_auth[each.key]] : []

      content {
        type     = authentication.value.type
        username = authentication.value.username
        password = authentication.value.password
      }
    }
  }

  depends_on = [
    local.docker_blobstore_depenecies
  ]

}

resource "nexus_repository_docker_group" "docker_remote_group" {

  name   = "docker-remote"
  online = true

  docker {
    force_basic_auth   = false
    path_based_routing = true
    v1_enabled         = true
  }

  group {
    member_names = local.docker_member_names
  }

  storage {
    blob_store_name                = "docker-remote"
    strict_content_type_validation = true
  }

  depends_on = [
    local.docker_blobstore_depenecies,
    nexus_repository_docker_proxy.docker_proxy
  ]
}

resource "nexus_repository_docker_group" "docker_group" {

  name   = "docker-group"
  online = true

  docker {
    force_basic_auth   = false
    path_based_routing = true
    v1_enabled         = true
  }

  group {
    member_names = local.docker_member_names
  }

  storage {
    blob_store_name                = "docker-remote"
    strict_content_type_validation = true
  }

  depends_on = [
    local.docker_blobstore_depenecies,
    nexus_repository_docker_proxy.docker_proxy
  ]
}

resource "nexus_security_role" "docker_proxy_role" {
  description = "docker read all proxy repositories"
  name        = "nx-read-docker-remote"
  privileges  = local.docker_privilege_names
  roleid      = "nx-read-docker-remote"

  depends_on = [
    nexus_repository_docker_proxy.docker_proxy
  ]
}
