locals {
  cocoapods_privilege_names = flatten([
    for key, list_value in var.cocoapods_remote_proxy : "nx-repository-view-cocoapods-cocoapods-remote-${key}-*"
  ])

  cocoapods_blobstore_depenecies = var.s3["enabled"] ? nexus_blobstore_s3.cocoapods_remote_blobstore_s3 : nexus_blobstore_file.cocoapods_remote_blobstore

  cocoapods_proxy_auth = {
    for key, value in var.cocoapods_remote_proxy : key => {
      type     = try(value.auth.type, try(var.cocoapods_remote_proxy_auth[key].type, "username"))
      username = trimspace(try(value.auth.username, try(var.cocoapods_remote_proxy_auth[key].username, "")))
      password = trimspace(try(value.auth.password, try(var.cocoapods_remote_proxy_auth[key].password, "")))
    }
  }
}

resource "nexus_blobstore_s3" "cocoapods_remote_blobstore_s3" {
  name = "cocoapods-remote"
  bucket_configuration {
    bucket {
      name       = "cocoapods-remote"
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

resource "nexus_blobstore_file" "cocoapods_remote_blobstore" {
  name  = "cocoapods-remote"
  path  = "cocoapods-remote"
  count = var.s3["enabled"] ? 0 : 1
}

resource "nexus_repository_cocoapods_proxy" "cocoapods_proxy" {
  for_each = var.cocoapods_remote_proxy

  name   = "cocoapods-remote-${each.key}"
  online = true

  storage {
    blob_store_name                = "cocoapods-remote"
    strict_content_type_validation = true
  }

  dynamic "cleanup" {
    for_each = var.attach_cleanup_policies ? [1] : []

    content {
      policy_names = ["cocoapods-remote-policy-30d"]
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
      for_each = local.cocoapods_proxy_auth[each.key].username != "" && local.cocoapods_proxy_auth[each.key].password != "" ? [local.cocoapods_proxy_auth[each.key]] : []
      content {
        type     = authentication.value.type
        username = authentication.value.username
        password = authentication.value.password
      }
    }
  }

  depends_on = [
    local.cocoapods_blobstore_depenecies
  ]
}

resource "nexus_security_role" "cocoapods_proxy_role" {
  description = "cocoapods read all proxy repositories"
  name        = "nx-read-cocoapods-remote"
  privileges  = local.cocoapods_privilege_names
  roleid      = "nx-read-cocoapods-remote"

  depends_on = [
    nexus_repository_cocoapods_proxy.cocoapods_proxy
  ]
}
