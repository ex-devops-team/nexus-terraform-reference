locals {
  go_member_names = flatten([
    for key, list_value in var.go_remote_proxy : "go-remote-${key}"
  ])

  go_privilege_names = flatten([
    for key, list_value in var.go_remote_proxy : "nx-repository-view-go-go-remote-${key}-*"
  ])

  go_blobstore_depenecies = var.s3["enabled"] ? nexus_blobstore_s3.go_remote_blobstore_s3 : nexus_blobstore_file.go_remote_blobstore

  go_proxy_auth = {
    for key, value in var.go_remote_proxy : key => {
      type     = try(value.auth.type, try(var.go_remote_proxy_auth[key].type, "username"))
      username = trimspace(try(value.auth.username, try(var.go_remote_proxy_auth[key].username, "")))
      password = trimspace(try(value.auth.password, try(var.go_remote_proxy_auth[key].password, "")))
    }
  }
}

resource "nexus_blobstore_s3" "go_remote_blobstore_s3" {
  name = "go-remote"
  bucket_configuration {
    bucket {
      name       = "go-remote"
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

resource "nexus_blobstore_file" "go_remote_blobstore" {
  name  = "go-remote"
  path  = "go-remote"
  count = var.s3["enabled"] ? 0 : 1
}

resource "nexus_repository_go_proxy" "go_proxy" {
  for_each = var.go_remote_proxy

  name   = "go-remote-${each.key}"
  online = true

  storage {
    blob_store_name                = "go-remote"
    strict_content_type_validation = true
  }

  dynamic "cleanup" {
    for_each = var.attach_cleanup_policies ? [1] : []

    content {
      policy_names = ["go-remote-policy-30d"]
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
      for_each = local.go_proxy_auth[each.key].username != "" && local.go_proxy_auth[each.key].password != "" ? [local.go_proxy_auth[each.key]] : []
      content {
        type     = authentication.value.type
        username = authentication.value.username
        password = authentication.value.password
      }
    }
  }

  depends_on = [
    local.go_blobstore_depenecies
  ]
}

resource "nexus_repository_go_group" "go_remote_group" {

  name   = "go-remote"
  online = true

  group {
    member_names = local.go_member_names
  }

  storage {
    blob_store_name                = "go-remote"
    strict_content_type_validation = true
  }

  depends_on = [
    local.go_blobstore_depenecies,
    nexus_repository_go_proxy.go_proxy
  ]
}

resource "nexus_security_role" "go_proxy_role" {
  description = "go read all proxy repositories"
  name        = "nx-read-go-remote"
  privileges  = local.go_privilege_names
  roleid      = "nx-read-go-remote"

  depends_on = [
    nexus_repository_go_proxy.go_proxy
  ]
}
