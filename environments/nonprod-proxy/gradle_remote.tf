locals {
  gradle_privilege_names = flatten([
    for key, list_value in var.gradle_remote_proxy : "nx-repository-view-maven2-gradle-remote-${key}-*"
  ])

  gradle_blobstore_depenecies = var.s3["enabled"] ? nexus_blobstore_s3.gradle_remote_blobstore_s3 : nexus_blobstore_file.gradle_remote_blobstore

  gradle_proxy_auth = {
    for key, value in var.gradle_remote_proxy : key => {
      type     = try(value.auth.type, try(var.gradle_remote_proxy_auth[key].type, "username"))
      username = trimspace(try(value.auth.username, try(var.gradle_remote_proxy_auth[key].username, "")))
      password = trimspace(try(value.auth.password, try(var.gradle_remote_proxy_auth[key].password, "")))
    }
  }
}

resource "nexus_blobstore_s3" "gradle_remote_blobstore_s3" {
  name = "gradle-remote"
  bucket_configuration {
    bucket {
      name       = "gradle-remote"
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

resource "nexus_blobstore_file" "gradle_remote_blobstore" {
  name  = "gradle-remote"
  path  = "gradle-remote"
  count = var.s3["enabled"] ? 0 : 1
}

resource "nexus_repository_maven_proxy" "gradle_proxy" {
  for_each = var.gradle_remote_proxy

  name   = "gradle-remote-${each.key}"
  online = true

  maven {
    version_policy      = "RELEASE"
    layout_policy       = "STRICT"
    content_disposition = "INLINE"
  }

  storage {
    blob_store_name                = "gradle-remote"
    strict_content_type_validation = true
  }

  dynamic "cleanup" {
    for_each = var.attach_cleanup_policies ? [1] : []

    content {
      policy_names = ["gradle-remote-policy-30d"]
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
      for_each = local.gradle_proxy_auth[each.key].username != "" && local.gradle_proxy_auth[each.key].password != "" ? [local.gradle_proxy_auth[each.key]] : []
      content {
        type     = authentication.value.type
        username = authentication.value.username
        password = authentication.value.password
      }
    }
  }

  depends_on = [
    local.gradle_blobstore_depenecies
  ]
}

resource "nexus_security_role" "gradle_proxy_role" {
  description = "gradle read all proxy repositories"
  name        = "nx-read-gradle-remote"
  privileges  = local.gradle_privilege_names
  roleid      = "nx-read-gradle-remote"

  depends_on = [
    nexus_repository_maven_proxy.gradle_proxy
  ]
}
