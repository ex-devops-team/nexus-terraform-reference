
locals {
  nuget_member_names = flatten([
    for key, list_value in var.nuget_remote_proxy : "nuget-remote-${key}"
  ])

  nuget_privilege_names = flatten([
    for key, list_value in var.nuget_remote_proxy : "nx-repository-view-nuget-nuget-remote-${key}-*"
  ])

  nuget_blobstore_depenecies = var.s3["enabled"] ? nexus_blobstore_s3.nuget_remote_blobstore_s3 : nexus_blobstore_file.nuget_remote_blobstore

  nuget_proxy_auth = {
    for key, value in var.nuget_remote_proxy : key => {
      type     = try(value.auth.type, try(var.nuget_remote_proxy_auth[key].type, "username"))
      username = trimspace(try(value.auth.username, try(var.nuget_remote_proxy_auth[key].username, "")))
      password = trimspace(try(value.auth.password, try(var.nuget_remote_proxy_auth[key].password, "")))
    }
  }
}

resource "nexus_blobstore_file" "nuget_remote_blobstore" {
  name  = "nuget-remote"
  path  = "nuget-remote"
  count = var.s3["enabled"] ? 0 : 1
}

resource "nexus_blobstore_s3" "nuget_remote_blobstore_s3" {
  name = "nuget-remote"
  bucket_configuration {
    bucket {
      name       = "nuget-remote"
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

resource "nexus_repository_nuget_proxy" "nuget_proxy" {
  for_each = var.nuget_remote_proxy

  name   = "nuget-remote-${each.key}"
  online = true

  nuget_version            = "V3"
  query_cache_item_max_age = 3600

  storage {
    blob_store_name                = "nuget-remote"
    strict_content_type_validation = true
  }

  dynamic "cleanup" {
    for_each = var.attach_cleanup_policies ? [1] : []

    content {
      policy_names = ["nuget-remote-policy-30d"]
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
      for_each = local.nuget_proxy_auth[each.key].username != "" && local.nuget_proxy_auth[each.key].password != "" ? [local.nuget_proxy_auth[each.key]] : []
      content {
        type     = authentication.value.type
        username = authentication.value.username
        password = authentication.value.password
      }
    }
  }

  depends_on = [
    local.nuget_blobstore_depenecies
  ]
}

resource "nexus_repository_nuget_group" "nuget_remote_group" {

  name   = "nuget-remote"
  online = true

  group {
    member_names = local.nuget_member_names
  }

  storage {
    blob_store_name                = "nuget-remote"
    strict_content_type_validation = true
  }

  depends_on = [
    local.nuget_blobstore_depenecies,
    nexus_repository_nuget_proxy.nuget_proxy
  ]
}

resource "nexus_security_role" "nuget_proxy_role" {
  description = "nuget read all proxy repositories"
  name        = "nx-read-nuget-remote"
  privileges  = local.nuget_privilege_names
  roleid      = "nx-read-nuget-remote"

  depends_on = [
    nexus_repository_nuget_proxy.nuget_proxy
  ]
}
