locals {
  conan_privilege_names = flatten([
    for key, list_value in var.conan_remote_proxy : "nx-repository-view-conan-conan-remote-${key}-*"
  ])

  conan_blobstore_depenecies = var.s3["enabled"] ? nexus_blobstore_s3.conan_remote_blobstore_s3 : nexus_blobstore_file.conan_remote_blobstore

  conan_proxy_auth = {
    for key, value in var.conan_remote_proxy : key => {
      type     = try(value.auth.type, try(var.conan_remote_proxy_auth[key].type, "username"))
      username = trimspace(try(value.auth.username, try(var.conan_remote_proxy_auth[key].username, "")))
      password = trimspace(try(value.auth.password, try(var.conan_remote_proxy_auth[key].password, "")))
    }
  }
}

resource "nexus_blobstore_s3" "conan_remote_blobstore_s3" {
  name = "conan-remote"
  bucket_configuration {
    bucket {
      name       = "conan-remote"
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

resource "nexus_blobstore_file" "conan_remote_blobstore" {
  name  = "conan-remote"
  path  = "conan-remote"
  count = var.s3["enabled"] ? 0 : 1
}

resource "nexus_repository_conan_proxy" "conan_proxy" {
  for_each = var.conan_remote_proxy

  name   = "conan-remote-${each.key}"
  online = true

  storage {
    blob_store_name                = "conan-remote"
    strict_content_type_validation = true
  }

  dynamic "cleanup" {
    for_each = var.attach_cleanup_policies ? [1] : []

    content {
      policy_names = ["conan-remote-policy-30d"]
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
      for_each = local.conan_proxy_auth[each.key].username != "" && local.conan_proxy_auth[each.key].password != "" ? [local.conan_proxy_auth[each.key]] : []
      content {
        type     = authentication.value.type
        username = authentication.value.username
        password = authentication.value.password
      }
    }
  }

  depends_on = [
    local.conan_blobstore_depenecies
  ]
}

resource "nexus_security_role" "conan_proxy_role" {
  description = "conan read all proxy repositories"
  name        = "nx-read-conan-remote"
  privileges  = local.conan_privilege_names
  roleid      = "nx-read-conan-remote"

  depends_on = [
    nexus_repository_conan_proxy.conan_proxy
  ]
}
