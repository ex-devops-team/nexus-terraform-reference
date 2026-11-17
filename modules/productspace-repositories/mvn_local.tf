locals {
  mvn_blobstore_depenecies = var.s3["enabled"] ? nexus_blobstore_s3.mvn_local_blobstore_s3 : nexus_blobstore_file.mvn_local_blobstore
}

resource "nexus_blobstore_s3" "mvn_local_blobstore_s3" {
  name = "mvn-local-${var.project.name}"
  bucket_configuration {
    bucket {
      name       = "mvn-local-${var.project.name}"
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
  count = var.project.mvn && var.s3["enabled"] ? 1 : 0

}
resource "nexus_blobstore_file" "mvn_local_blobstore" {
  count = var.project.mvn && !var.s3["enabled"] ? 1 : 0
  name  = "mvn-local-${var.project.name}"
  path  = "mvn-local-${var.project.name}"
}

resource "nexus_repository_maven_hosted" "maven_local_project_releases" {
  count = var.project.mvn ? 1 : 0

  name   = "mvn-local-${var.project.name}-releases"
  online = true

  storage {
    blob_store_name                = "mvn-local-${var.project.name}"
    strict_content_type_validation = true
    write_policy                   = "ALLOW_ONCE"
  }

  maven {
    version_policy      = "RELEASE"
    layout_policy       = "STRICT"
    content_disposition = "INLINE"
  }

  depends_on = [
    local.mvn_blobstore_depenecies
  ]
}

resource "nexus_repository_maven_hosted" "maven_local_project_snapshots" {
  count = var.project.mvn ? 1 : 0

  name   = "mvn-local-${var.project.name}-snapshots"
  online = true

  storage {
    blob_store_name                = "mvn-local-${var.project.name}"
    strict_content_type_validation = true
    write_policy                   = "ALLOW_ONCE"
  }

  maven {
    version_policy      = "SNAPSHOT"
    layout_policy       = "STRICT"
    content_disposition = "INLINE"
  }

  depends_on = [
    local.mvn_blobstore_depenecies
  ]
}

resource "nexus_repository_maven_group" "maven_local_project_group" {
  count = var.project.mvn ? 1 : 0

  name   = "mvn-${var.project.name}"
  online = true

  group {
    member_names = compact(concat(
      [
        nexus_repository_maven_hosted.maven_local_project_snapshots[0].name,
        nexus_repository_maven_hosted.maven_local_project_releases[0].name,
        "mvn-remote",
      ],
      try(var.project.mvn_extra_repos, [])
    ))
  }

  storage {
    blob_store_name                = "mvn-local-${var.project.name}"
    strict_content_type_validation = true
  }

  depends_on = [
    nexus_repository_maven_hosted.maven_local_project_releases,
    nexus_repository_maven_hosted.maven_local_project_snapshots
  ]
}
