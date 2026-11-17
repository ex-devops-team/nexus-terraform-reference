locals {
  mvn_privilege_names = flatten([
    for key, list_value in var.mvn_remote_proxy : "nx-repository-view-maven2-mvn-remote-${key}-*"
  ])

  mvn_member_names = flatten([
    for key, list_value in var.mvn_remote_proxy : "mvn-remote-${key}"
  ])

  mvn_blobstore_depenecies = var.s3["enabled"] ? nexus_blobstore_s3.mvn_remote_blobstore_s3 : nexus_blobstore_file.mvn_remote_blobstore

  mvn_proxy_auth = {
    for key, value in var.mvn_remote_proxy : key => {
      type     = try(value.auth.type, try(var.mvn_remote_proxy_auth[key].type, "username"))
      username = trimspace(try(value.auth.username, try(var.mvn_remote_proxy_auth[key].username, "")))
      password = trimspace(try(value.auth.password, try(var.mvn_remote_proxy_auth[key].password, "")))
    }
  }
}

resource "nexus_blobstore_s3" "mvn_remote_blobstore_s3" {
  name = "mvn-remote"
  bucket_configuration {
    bucket {
      name       = "mvn-remote"
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

resource "nexus_blobstore_file" "mvn_remote_blobstore" {
  name  = "mvn-remote"
  path  = "mvn-remote"
  count = var.s3["enabled"] ? 0 : 1
}

resource "nexus_repository_maven_proxy" "mvn_proxy" {
  for_each = var.mvn_remote_proxy

  name   = "mvn-remote-${each.key}"
  online = true

  maven {
    version_policy      = "RELEASE"
    layout_policy       = "STRICT"
    content_disposition = "INLINE"
  }

  storage {
    blob_store_name                = "mvn-remote"
    strict_content_type_validation = true
  }

  dynamic "cleanup" {
    for_each = var.attach_cleanup_policies ? [1] : []

    content {
      policy_names = ["mvn-remote-policy-30d"]
    }
  }

  proxy {
    remote_url       = each.value.url
    content_max_age  = -1
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
      for_each = local.mvn_proxy_auth[each.key].username != "" && local.mvn_proxy_auth[each.key].password != "" ? [local.mvn_proxy_auth[each.key]] : []
      content {
        type     = authentication.value.type
        username = authentication.value.username
        password = authentication.value.password
      }
    }
  }

  depends_on = [
    local.mvn_blobstore_depenecies
  ]
}

resource "nexus_repository_maven_group" "mvn_proxy_group" {

  name   = "mvn-remote"
  online = true

  group {
    member_names = local.mvn_member_names
  }

  storage {
    blob_store_name                = "mvn-remote"
    strict_content_type_validation = true
  }

  depends_on = [
    local.mvn_blobstore_depenecies,
    nexus_repository_maven_proxy.mvn_proxy
  ]
}

resource "nexus_security_role" "mvn_proxy_role" {
  description = "mvn read all proxy repositories"
  name        = "nx-read-mvn-remote"
  privileges  = local.mvn_privilege_names
  roleid      = "nx-read-mvn-remote"

  depends_on = [
    nexus_repository_maven_proxy.mvn_proxy
  ]
}
