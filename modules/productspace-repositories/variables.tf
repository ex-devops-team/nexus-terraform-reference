variable "s3" {
  type = map(any)
  default = {
    url        = "https://minio.example.com"
    region     = "us-central-1"
    expiration = 90
    path_style = true
    access_key = ""
    secret_key = ""
    enabled    = false
  }
}

variable "project" {
  description = "Project object"
  type = object({
    name               = string
    docker             = optional(bool, true)
    mvn                = optional(bool, false)
    npm                = optional(bool, false)
    cargo              = optional(bool, false)
    raw                = optional(bool, false)
    helm               = optional(bool, false)
    pypi               = optional(bool, false)
    user_manual_create = optional(bool, false)
    user_extra_roles   = optional(list(string), [""])
    docker_extra_repos = optional(list(string), [""])
    mvn_extra_repos    = optional(list(string), [""])
    npm_extra_repos    = optional(list(string), [""])
    cargo_extra_repos  = optional(list(string), [""])
    pip_extra_repos    = optional(list(string), [""])
  })

  default = (
    {
      name               = "project1"
      docker             = true
      mvn                = false
      npm                = false
      cargo              = false
      raw                = false
      helm               = false
      pypi               = false
      user_manual_create = false
      user_extra_roles   = [""]
      docker_extra_repos = [""]
      mvn_extra_repos    = [""]
      npm_extra_repos    = [""]
      cargo_extra_repos  = [""]
      pip_extra_repos    = [""]
    }
  )
}
