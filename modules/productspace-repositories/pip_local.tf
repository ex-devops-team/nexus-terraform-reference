locals {
  pypi_blobstore_depenecies = var.s3["enabled"] ? nexus_blobstore_s3.pypi_local_blobstore_s3 : nexus_blobstore_file.pypi_local_blobstore
}

resource "nexus_blobstore_s3" "pypi_local_blobstore_s3" {
  name = "pip-local-${var.project.name}"
  bucket_configuration {
    bucket {
      name       = "pip-local-${var.project.name}"
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
  count = var.project.pypi && var.s3["enabled"] ? 1 : 0

}
resource "nexus_blobstore_file" "pypi_local_blobstore" {
  count = var.project.pypi && !var.s3["enabled"] ? 1 : 0
  name  = "pip-local-${var.project.name}"
  path  = "pip-local-${var.project.name}"
}

resource "nexus_repository_pypi_hosted" "pypi_local_project" {
  count = var.project.pypi ? 1 : 0

  name   = "pip-local-${var.project.name}"
  online = true

  storage {
    blob_store_name                = "pip-local-${var.project.name}"
    strict_content_type_validation = true
  }

  component {
    proprietary_components = true
  }

  depends_on = [
    local.pypi_blobstore_depenecies
  ]
}

resource "nexus_repository_pypi_group" "pypi_local_project_group" {
  count = var.project.pypi ? 1 : 0

  name   = "pip-${var.project.name}"
  online = true

  group {
    member_names = compact(concat(
      [
        nexus_repository_pypi_hosted.pypi_local_project[0].name,
        "pip-remote",
      ],
      try(var.project.pip_extra_repos, [])
    ))
  }

  storage {
    blob_store_name                = "pip-local-${var.project.name}"
    strict_content_type_validation = true
  }

  depends_on = [
    local.pypi_blobstore_depenecies
  ]
}
