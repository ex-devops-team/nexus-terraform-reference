locals {
  apt_privilege_names = flatten([
    for key, list_value in var.apt_remote_proxy : "nx-repository-view-apt-apt-remote-${key}-*"
  ])

  apt_blobstore_depenecies = var.s3["enabled"] ? nexus_blobstore_s3.apt_remote_blobstore_s3 : nexus_blobstore_file.apt_remote_blobstore

  apt_proxy_auth = {
    for key, value in var.apt_remote_proxy : key => {
      type     = try(value.auth.type, try(var.apt_remote_proxy_auth[key].type, "username"))
      username = trimspace(try(value.auth.username, try(var.apt_remote_proxy_auth[key].username, "")))
      password = trimspace(try(value.auth.password, try(var.apt_remote_proxy_auth[key].password, "")))
    }
  }
}

resource "nexus_blobstore_s3" "apt_remote_blobstore_s3" {
  name = "apt-remote"
  bucket_configuration {
    bucket {
      name       = "apt-remote"
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

resource "nexus_blobstore_file" "apt_remote_blobstore" {
  name  = "apt-remote"
  path  = "apt-remote"
  count = var.s3["enabled"] ? 0 : 1
}

resource "nexus_repository_apt_proxy" "apt_proxy" {
  for_each = var.apt_remote_proxy

  name   = "apt-remote-${each.key}"
  online = true

  distribution = each.value.distribution
  flat         = try(each.value.flat, false)

  storage {
    blob_store_name                = "apt-remote"
    strict_content_type_validation = true
  }

  dynamic "cleanup" {
    for_each = var.attach_cleanup_policies ? [1] : []

    content {
      policy_names = ["apt-remote-policy-30d"]
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
      for_each = local.apt_proxy_auth[each.key].username != "" && local.apt_proxy_auth[each.key].password != "" ? [local.apt_proxy_auth[each.key]] : []
      content {
        type     = authentication.value.type
        username = authentication.value.username
        password = authentication.value.password
      }
    }
  }

  depends_on = [
    local.apt_blobstore_depenecies
  ]
}

resource "nexus_security_role" "apt_proxy_role" {
  description = "apt read all proxy repositories"
  name        = "nx-read-apt-remote"
  privileges  = local.apt_privilege_names
  roleid      = "nx-read-apt-remote"

  depends_on = [
    nexus_repository_apt_proxy.apt_proxy
  ]
}
