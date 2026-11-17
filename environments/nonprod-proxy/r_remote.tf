locals {
  r_member_names = flatten([
    for key, list_value in var.r_remote_proxy : "r-remote-${key}"
  ])

  r_privilege_names = flatten([
    for key, list_value in var.r_remote_proxy : "nx-repository-view-r-r-remote-${key}-*"
  ])

  r_blobstore_depenecies = var.s3["enabled"] ? nexus_blobstore_s3.r_remote_blobstore_s3 : nexus_blobstore_file.r_remote_blobstore

  r_proxy_auth = {
    for key, value in var.r_remote_proxy : key => {
      type     = try(value.auth.type, try(var.r_remote_proxy_auth[key].type, "username"))
      username = trimspace(try(value.auth.username, try(var.r_remote_proxy_auth[key].username, "")))
      password = trimspace(try(value.auth.password, try(var.r_remote_proxy_auth[key].password, "")))
    }
  }
}

resource "nexus_blobstore_s3" "r_remote_blobstore_s3" {
  name = "r-remote"
  bucket_configuration {
    bucket {
      name       = "r-remote"
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

resource "nexus_blobstore_file" "r_remote_blobstore" {
  name  = "r-remote"
  path  = "r-remote"
  count = var.s3["enabled"] ? 0 : 1
}

resource "nexus_repository_r_proxy" "r_proxy" {
  for_each = var.r_remote_proxy

  name   = "r-remote-${each.key}"
  online = true

  storage {
    blob_store_name                = "r-remote"
    strict_content_type_validation = true
  }

  dynamic "cleanup" {
    for_each = var.attach_cleanup_policies ? [1] : []

    content {
      policy_names = ["r-remote-policy-30d"]
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
      for_each = local.r_proxy_auth[each.key].username != "" && local.r_proxy_auth[each.key].password != "" ? [local.r_proxy_auth[each.key]] : []
      content {
        type     = authentication.value.type
        username = authentication.value.username
        password = authentication.value.password
      }
    }
  }

  depends_on = [
    local.r_blobstore_depenecies
  ]
}

resource "nexus_repository_r_group" "r_remote_group" {
  name   = "r-remote"
  online = true

  group {
    member_names = local.r_member_names
  }

  storage {
    blob_store_name                = "r-remote"
    strict_content_type_validation = true
  }

  depends_on = [
    local.r_blobstore_depenecies,
    nexus_repository_r_proxy.r_proxy
  ]
}

resource "nexus_security_role" "r_proxy_role" {
  description = "r read all proxy repositories"
  name        = "nx-read-r-remote"
  privileges  = local.r_privilege_names
  roleid      = "nx-read-r-remote"

  depends_on = [
    nexus_repository_r_proxy.r_proxy
  ]
}
