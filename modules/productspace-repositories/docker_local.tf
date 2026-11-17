locals {
  docker_blobstore_depenecies = var.s3["enabled"] ? nexus_blobstore_s3.docker_local_blobstore_s3 : nexus_blobstore_file.docker_local_blobstore
}

resource "nexus_blobstore_s3" "docker_local_blobstore_s3" {
  name = "docker-local-${var.project.name}"
  bucket_configuration {
    bucket {
      name       = "docker-local-${var.project.name}"
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
  count = var.project.docker && var.s3["enabled"] ? 1 : 0

}
resource "nexus_blobstore_file" "docker_local_blobstore" {
  count = var.project.docker && !var.s3["enabled"] ? 1 : 0
  name  = "docker-local-${var.project.name}"
  path  = "docker-local-${var.project.name}"
}

resource "nexus_repository_docker_hosted" "docker_local_project_dev" {
  count = var.project.docker ? 1 : 0

  name   = "docker-local-${var.project.name}-dev"
  online = true

  docker {
    force_basic_auth = false
    v1_enabled       = false
  }

  storage {
    blob_store_name                = "docker-local-${var.project.name}"
    strict_content_type_validation = true
    write_policy                   = "ALLOW"
  }

  cleanup {
    policy_names = (["docker-local-15days"])
  }

  component {
    proprietary_components = true
  }

  depends_on = [
    local.docker_blobstore_depenecies
  ]
}

resource "nexus_repository_docker_hosted" "docker_local_project_prod" {
  count = var.project.docker ? 1 : 0

  name   = "docker-local-${var.project.name}-prod"
  online = true

  docker {
    force_basic_auth = false
    v1_enabled       = false
  }

  storage {
    blob_store_name                = "docker-local-${var.project.name}"
    strict_content_type_validation = true
    write_policy                   = "ALLOW_ONCE"
  }

  cleanup {
    policy_names = (["docker-local-180days"])
  }

  component {
    proprietary_components = true
  }

  depends_on = [
    local.docker_blobstore_depenecies
  ]
}


resource "nexus_repository_docker_group" "docker_local_project_group" {
  count = var.project.docker ? 1 : 0

  name   = "docker-${var.project.name}"
  online = true

  docker {
    force_basic_auth = false
    v1_enabled       = false
  }

  group {
    member_names = compact(concat(
      [
        nexus_repository_docker_hosted.docker_local_project_dev[0].name,
        nexus_repository_docker_hosted.docker_local_project_prod[0].name,
        "docker-remote",
      ],
      try(var.project.docker_extra_repos, [])
    ))
  }

  storage {
    blob_store_name                = "docker-local-${var.project.name}"
    strict_content_type_validation = true
  }

  depends_on = [
    nexus_repository_docker_hosted.docker_local_project_dev,
    nexus_repository_docker_hosted.docker_local_project_prod
  ]
}
