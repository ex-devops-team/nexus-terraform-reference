locals {
  terraform_privilege_names = flatten([
    for key, list_value in var.terraform_remote_proxy : "nx-repository-view-raw-terraform-remote-${key}-*"
  ])

  terraform_blobstore_depenecies = var.s3["enabled"] ? nexus_blobstore_s3.terraform_remote_blobstore_s3 : nexus_blobstore_file.terraform_remote_blobstore

  terraform_proxy_auth = {
    for key, value in var.terraform_remote_proxy : key => {
      type     = try(value.auth.type, try(var.terraform_remote_proxy_auth[key].type, "username"))
      username = trimspace(try(value.auth.username, try(var.terraform_remote_proxy_auth[key].username, "")))
      password = trimspace(try(value.auth.password, try(var.terraform_remote_proxy_auth[key].password, "")))
    }
  }
}

resource "nexus_blobstore_s3" "terraform_remote_blobstore_s3" {
  name = "terraform-remote"
  bucket_configuration {
    bucket {
      name       = "terraform-remote"
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

resource "nexus_blobstore_file" "terraform_remote_blobstore" {
  name  = "terraform-remote"
  path  = "terraform-remote"
  count = var.s3["enabled"] ? 0 : 1
}

resource "nexus_repository_raw_proxy" "terraform_proxy" {
  for_each = var.terraform_remote_proxy

  name   = "terraform-remote-${each.key}"
  online = true

  storage {
    blob_store_name                = "terraform-remote"
    strict_content_type_validation = true
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
      for_each = local.terraform_proxy_auth[each.key].username != "" && local.terraform_proxy_auth[each.key].password != "" ? [local.terraform_proxy_auth[each.key]] : []
      content {
        type     = authentication.value.type
        username = authentication.value.username
        password = authentication.value.password
      }
    }
  }

  depends_on = [
    local.terraform_blobstore_depenecies
  ]
}

resource "nexus_security_role" "terraform_proxy_role" {
  description = "terraform read all proxy repositories"
  name        = "nx-read-terraform-remote"
  privileges  = local.terraform_privilege_names
  roleid      = "nx-read-terraform-remote"

  depends_on = [
    nexus_repository_raw_proxy.terraform_proxy
  ]
}
