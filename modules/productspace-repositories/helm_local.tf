locals {
  helm_blobstore_depenecies = var.s3["enabled"] ? nexus_blobstore_s3.helm_local_blobstore_s3 : nexus_blobstore_file.helm_local_blobstore
}

resource "nexus_blobstore_s3" "helm_local_blobstore_s3" {
  name = "helm-local-${var.project.name}"
  bucket_configuration {
    bucket {
      name       = "helm-local-${var.project.name}"
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
  count = var.project.helm && var.s3["enabled"] ? 1 : 0

}

resource "nexus_blobstore_file" "helm_local_blobstore" {
  count = var.project.helm && !var.s3["enabled"] ? 1 : 0
  name  = "helm-local-${var.project.name}"
  path  = "helm-local-${var.project.name}"
}

resource "nexus_repository_helm_hosted" "helm_local_project" {
  count = var.project.helm ? 1 : 0

  name   = "helm-local-${var.project.name}"
  online = true

  storage {
    blob_store_name                = "helm-local-${var.project.name}"
    strict_content_type_validation = true
  }

  depends_on = [
    local.helm_blobstore_depenecies
  ]
}
