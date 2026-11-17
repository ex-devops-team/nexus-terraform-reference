locals {
  yum_member_names = flatten([
    for key, list_value in var.yum_remote_proxy : "yum-remote-${key}"
  ])

  yum_privilege_names = flatten([
    for key, list_value in var.yum_remote_proxy : "nx-repository-view-yum-yum-remote-${key}-*"
  ])

  yum_blobstore_depenecies = var.s3["enabled"] ? nexus_blobstore_s3.yum_remote_blobstore_s3 : nexus_blobstore_file.yum_remote_blobstore

  yum_proxy_auth = {
    for key, value in var.yum_remote_proxy : key => {
      type     = try(value.auth.type, try(var.yum_remote_proxy_auth[key].type, "username"))
      username = trimspace(try(value.auth.username, try(var.yum_remote_proxy_auth[key].username, "")))
      password = trimspace(try(value.auth.password, try(var.yum_remote_proxy_auth[key].password, "")))
    }
  }
}

resource "nexus_blobstore_s3" "yum_remote_blobstore_s3" {
  name = "yum-remote"
  bucket_configuration {
    bucket {
      name       = "yum-remote"
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

resource "nexus_blobstore_file" "yum_remote_blobstore" {
  name  = "yum-remote"
  path  = "yum-remote"
  count = var.s3["enabled"] ? 0 : 1
}

resource "nexus_repository_yum_proxy" "yum_proxy" {
  for_each = var.yum_remote_proxy

  name   = "yum-remote-${each.key}"
  online = true

  storage {
    blob_store_name                = "yum-remote"
    strict_content_type_validation = true
  }

  dynamic "cleanup" {
    for_each = var.attach_cleanup_policies ? [1] : []

    content {
      policy_names = ["yum-remote-policy-30d"]
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
      for_each = local.yum_proxy_auth[each.key].username != "" && local.yum_proxy_auth[each.key].password != "" ? [local.yum_proxy_auth[each.key]] : []
      content {
        type     = authentication.value.type
        username = authentication.value.username
        password = authentication.value.password
      }
    }
  }

  depends_on = [
    local.yum_blobstore_depenecies
  ]
}

resource "nexus_repository_yum_group" "yum_remote_group" {
  name   = "yum-remote"
  online = true

  group {
    member_names = local.yum_member_names
  }

  storage {
    blob_store_name                = "yum-remote"
    strict_content_type_validation = true
  }

  depends_on = [
    local.yum_blobstore_depenecies,
    nexus_repository_yum_proxy.yum_proxy
  ]
}

resource "nexus_security_role" "yum_proxy_role" {
  description = "yum read all proxy repositories"
  name        = "nx-read-yum-remote"
  privileges  = local.yum_privilege_names
  roleid      = "nx-read-yum-remote"

  depends_on = [
    nexus_repository_yum_proxy.yum_proxy
  ]
}
