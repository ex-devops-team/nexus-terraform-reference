locals {
  npm_member_names = flatten([
    for key, list_value in var.npm_remote_proxy : "npm-remote-${key}"
  ])

  npm_privilege_names = flatten([
    for key, list_value in var.npm_remote_proxy : "nx-repository-view-npm-npm-remote-${key}-*"
  ])

  npm_blobstore_depenecies = var.s3["enabled"] ? nexus_blobstore_s3.npm_remote_blobstore_s3 : nexus_blobstore_file.npm_remote_blobstore

  npm_proxy_auth = {
    for key, value in var.npm_remote_proxy : key => {
      type     = try(value.auth.type, try(var.npm_remote_proxy_auth[key].type, "username"))
      username = trimspace(try(value.auth.username, try(var.npm_remote_proxy_auth[key].username, "")))
      password = trimspace(try(value.auth.password, try(var.npm_remote_proxy_auth[key].password, "")))
    }
  }
}

resource "nexus_blobstore_s3" "npm_remote_blobstore_s3" {
  name = "npm-remote"
  bucket_configuration {
    bucket {
      name       = "npm-remote"
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

resource "nexus_blobstore_file" "npm_remote_blobstore" {
  name  = "npm-remote"
  path  = "npm-remote"
  count = var.s3["enabled"] ? 0 : 1
}

resource "nexus_repository_npm_proxy" "npm_proxy" {
  for_each = var.npm_remote_proxy

  name   = "npm-remote-${each.key}"
  online = true

  storage {
    blob_store_name                = "npm-remote"
    strict_content_type_validation = true
  }

  dynamic "cleanup" {
    for_each = var.attach_cleanup_policies ? [1] : []

    content {
      policy_names = ["npm-remote-policy-30d"]
    }
  }

  proxy {
    remote_url       = each.value.url
    content_max_age  = -1
    metadata_max_age = 60
  }

  negative_cache {
    enabled = true
    ttl     = 1440
  }

  http_client {
    blocked    = false
    auto_block = true

    dynamic "authentication" {
      for_each = local.npm_proxy_auth[each.key].username != "" && local.npm_proxy_auth[each.key].password != "" ? [local.npm_proxy_auth[each.key]] : []
      content {
        type     = authentication.value.type
        username = authentication.value.username
        password = authentication.value.password
      }
    }
  }

  depends_on = [
    local.npm_blobstore_depenecies
  ]
}

resource "nexus_repository_npm_group" "npm_remote_group" {

  name   = "npm-remote"
  online = true

  group {
    member_names = local.npm_member_names
  }

  storage {
    blob_store_name                = "npm-remote"
    strict_content_type_validation = true
  }

  depends_on = [
    local.npm_blobstore_depenecies,
    nexus_repository_npm_proxy.npm_proxy
  ]
}

resource "nexus_security_role" "npm_proxy_role" {
  description = "npm read all proxy repositories"
  name        = "nx-read-npm-remote"
  privileges  = local.npm_privilege_names
  roleid      = "nx-read-npm-remote"

  depends_on = [
    nexus_repository_npm_proxy.npm_proxy
  ]
}
