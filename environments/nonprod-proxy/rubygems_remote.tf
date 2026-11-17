locals {
  rubygems_member_names = flatten([
    for key, list_value in var.rubygems_remote_proxy : "rubygems-remote-${key}"
  ])

  rubygems_privilege_names = flatten([
    for key, list_value in var.rubygems_remote_proxy : "nx-repository-view-rubygems-rubygems-remote-${key}-*"
  ])

  rubygems_blobstore_depenecies = var.s3["enabled"] ? nexus_blobstore_s3.rubygems_remote_blobstore_s3 : nexus_blobstore_file.rubygems_remote_blobstore

  rubygems_proxy_auth = {
    for key, value in var.rubygems_remote_proxy : key => {
      type     = try(value.auth.type, try(var.rubygems_remote_proxy_auth[key].type, "username"))
      username = trimspace(try(value.auth.username, try(var.rubygems_remote_proxy_auth[key].username, "")))
      password = trimspace(try(value.auth.password, try(var.rubygems_remote_proxy_auth[key].password, "")))
    }
  }
}

resource "nexus_blobstore_s3" "rubygems_remote_blobstore_s3" {
  name = "rubygems-remote"
  bucket_configuration {
    bucket {
      name       = "rubygems-remote"
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

resource "nexus_blobstore_file" "rubygems_remote_blobstore" {
  name  = "rubygems-remote"
  path  = "rubygems-remote"
  count = var.s3["enabled"] ? 0 : 1
}

resource "nexus_repository_rubygems_proxy" "rubygems_proxy" {
  for_each = var.rubygems_remote_proxy

  name   = "rubygems-remote-${each.key}"
  online = true

  storage {
    blob_store_name                = "rubygems-remote"
    strict_content_type_validation = true
  }

  dynamic "cleanup" {
    for_each = var.attach_cleanup_policies ? [1] : []

    content {
      policy_names = ["rubygems-remote-policy-30d"]
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
      for_each = local.rubygems_proxy_auth[each.key].username != "" && local.rubygems_proxy_auth[each.key].password != "" ? [local.rubygems_proxy_auth[each.key]] : []
      content {
        type     = authentication.value.type
        username = authentication.value.username
        password = authentication.value.password
      }
    }
  }

  depends_on = [
    local.rubygems_blobstore_depenecies
  ]
}

resource "nexus_repository_rubygems_group" "rubygems_remote_group" {
  name   = "rubygems-remote"
  online = true

  group {
    member_names = local.rubygems_member_names
  }

  storage {
    blob_store_name                = "rubygems-remote"
    strict_content_type_validation = true
  }

  depends_on = [
    local.rubygems_blobstore_depenecies,
    nexus_repository_rubygems_proxy.rubygems_proxy
  ]
}

resource "nexus_security_role" "rubygems_proxy_role" {
  description = "rubygems read all proxy repositories"
  name        = "nx-read-rubygems-remote"
  privileges  = local.rubygems_privilege_names
  roleid      = "nx-read-rubygems-remote"

  depends_on = [
    nexus_repository_rubygems_proxy.rubygems_proxy
  ]
}
