locals {
  cargo_blobstore_depenecies = var.s3["enabled"] ? nexus_blobstore_s3.cargo_local_blobstore_s3 : nexus_blobstore_file.cargo_local_blobstore
}

resource "nexus_blobstore_s3" "cargo_local_blobstore_s3" {
  name = "cargo-local-${var.project.name}"
  bucket_configuration {
    bucket {
      name       = "cargo-local-${var.project.name}"
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
  count = var.project.cargo && var.s3["enabled"] ? 1 : 0

}
resource "nexus_blobstore_file" "cargo_local_blobstore" {
  count = var.project.cargo && !var.s3["enabled"] ? 1 : 0
  name  = "cargo-local-${var.project.name}"
  path  = "cargo-local-${var.project.name}"
}

resource "nexus_repository_cargo_hosted" "cargo_local_project" {
  count = var.project.cargo ? 1 : 0

  name   = "cargo-local-${var.project.name}"
  online = true

  storage {
    blob_store_name                = "cargo-local-${var.project.name}"
    strict_content_type_validation = true
    write_policy                   = "ALLOW"
  }

  depends_on = [
    local.cargo_blobstore_depenecies
  ]
}

resource "nexus_repository_cargo_group" "cargo_local_project_group" {
  count = var.project.cargo ? 1 : 0

  name   = "cargo-${var.project.name}"
  online = true

  group {
    member_names = compact(concat(
      [
        nexus_repository_cargo_hosted.cargo_local_project[0].name,
        "cargo-remote",
      ],
      try(var.project.cargo_extra_repos, [])
    ))
  }

  storage {
    blob_store_name                = "cargo-local-${var.project.name}"
    strict_content_type_validation = true
  }

  depends_on = [
    local.cargo_blobstore_depenecies
  ]
}
