variable "nexus_insecure" {
  description = "Disable Nexus TLS verification only for an explicitly accepted disposable local PoC. Keep false for shared and production environments."
  type        = bool
  default     = false
}

variable "s3" {
  description = "S3-compatible blobstore configuration. Set enabled=true and fill credentials to use S3/Minio instead of local filesystem for all blob stores."
  type        = map(any)
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

variable "attach_cleanup_policies" {
  description = "Attach the complete pre-existing <format>-remote-policy-30d cleanup policy set to proxy repositories. Keep false unless the target owner has confirmed entitlement plus native existence and criteria readback for every referenced policy; partial attachment is unsupported."
  type        = bool
  default     = false
}

variable "docker_remote_proxy" {
  description = "Map of Docker proxy repositories to create. Each key becomes the repo name suffix (docker-remote-<key>). Supports index (HUB|REGISTRY), url, anonymous_access, and optional inline auth block."
  type        = map(any)
  default = {
    dockerhub = {
      index            = "HUB"
      url              = "https://registry-1.docker.io"
      anonymous_access = true
    }
    mcr = {
      index            = "REGISTRY"
      url              = "https://mcr.microsoft.com"
      anonymous_access = true
    },
    k8s = {
      index            = "REGISTRY"
      url              = "https://registry.k8s.io"
      anonymous_access = true
    },
    gitlab = {
      index            = "REGISTRY"
      url              = "https://registry.gitlab.com"
      anonymous_access = true
    },
    quay = {
      index            = "REGISTRY"
      url              = "https://quay.io"
      anonymous_access = true
    },
    ghcr = {
      index            = "REGISTRY"
      url              = "https://ghcr.io"
      anonymous_access = true
    },
    gcr = {
      index            = "REGISTRY"
      url              = "https://k8s.gcr.io"
      anonymous_access = true
    },
    gcr-io = {
      index            = "REGISTRY"
      url              = "https://gcr.io"
      anonymous_access = true
    },
    yandex = {
      index            = "REGISTRY"
      url              = "https://cr.yandex"
      anonymous_access = true
    },
    deckhouse = {
      index            = "REGISTRY"
      url              = "https://registry.deckhouse.io"
      anonymous_access = true
    }
    nvcr = {
      index            = "REGISTRY"
      url              = "https://nvcr.io"
      anonymous_access = true
    }
    elastic = {
      index            = "REGISTRY"
      url              = "https://docker.elastic.co"
      anonymous_access = true
    }
  }
}

variable "docker_remote_proxy_auth" {
  description = "Optional upstream auth per docker proxy repo, e.g. { dockerhub = { username = \"...\", password = \"...\" } }"
  type = map(object({
    username = string
    password = string
    type     = optional(string, "username")
  }))
  default   = {}
  sensitive = true
}

variable "mvn_remote_proxy_auth" {
  description = "Optional upstream auth per mvn proxy repo, e.g. { central = { username = \"...\", password = \"...\" } }"
  type = map(object({
    username = string
    password = string
    type     = optional(string, "username")
  }))
  default   = {}
  sensitive = true
}

variable "mvn_remote_proxy" {
  description = "Map of Maven 2 proxy repositories (mvn-remote-<key>). Each entry requires url; optional anonymous_access and inline auth block. CI var: TF_VAR_mvn_remote_proxy."
  type        = map(any)

  default = {
    central = {
      url              = "https://repo1.maven.org/maven2"
      anonymous_access = true
    }
    jboss = {
      url              = "https://repository.jboss.org/nexus/content/groups/public/org"
      anonymous_access = true
    },
    spring = {
      url              = "https://repo.spring.io/ui/native/libs-milestone"
      anonymous_access = true
    },
    jitpack = {
      url              = "https://jitpack.io"
      anonymous_access = true
    }
    spring-release = {
      url              = "https://repo.spring.io/ui/native/libs-release"
      anonymous_access = true
    }
    geomajas = {
      url              = "http://maven.geomajas.org"
      anonymous_access = true
    }
  }
}

variable "helm_remote_proxy_auth" {
  description = "Optional upstream auth per helm proxy repo, e.g. { bitnami = { username = \"...\", password = \"...\" } }"
  type = map(object({
    username = string
    password = string
    type     = optional(string, "username")
  }))
  default   = {}
  sensitive = true
}

variable "helm_remote_proxy" {
  description = "Map of Helm proxy repositories (helm-remote-<key>). Each entry requires url; optional anonymous_access and inline auth block. CI var: TF_VAR_helm_remote_proxy."
  type        = map(any)

  default = {
    awx = {
      url              = "https://ansible-community.github.io/awx-operator-helm"
      anonymous_access = true
    }
    dex = {
      url              = "https://charts.dexidp.io"
      anonymous_access = true
    }
    bitnami = {
      url              = "https://charts.bitnami.com/bitnami"
      anonymous_access = true
    }
    prometheus = {
      url              = "https://prometheus-community.github.io/helm-charts"
      anonymous_access = true
    },
    grafana = {
      url              = "https://grafana.github.io/helm-charts"
      anonymous_access = true
    },
    istio = {
      url              = "https://istio-release.storage.googleapis.com/charts"
      anonymous_access = true
    }
    elastic = {
      url              = "https://helm.elastic.co/helm"
      anonymous_access = true
    }
    cnpg = {
      url              = "https://cloudnative-pg.github.io/charts"
      anonymous_access = true
    }
    couchbase = {
      url              = "https://couchbase-partners.github.io/helm-charts"
      anonymous_access = true
    }
    altinity = {
      url              = "https://helm.altinity.com"
      anonymous_access = true
    }
    gitlab = {
      url              = "https://charts.gitlab.io"
      anonymous_access = true
    }
    opentelemetry = {
      url              = "https://open-telemetry.github.io/opentelemetry-helm-charts"
      anonymous_access = true
    }
  }
}

# TODO: Hugging Face support is temporarily disabled.
# Re-check provider support later: https://github.com/datadrivers/terraform-provider-nexus/issues/549

variable "gradle_remote_proxy_auth" {
  description = "Optional upstream auth per gradle proxy repo, e.g. { plugins = { username = \"...\", password = \"...\" } }"
  type = map(object({
    username = string
    password = string
    type     = optional(string, "username")
  }))
  default   = {}
  sensitive = true
}

variable "gradle_remote_proxy" {
  description = "Map of Gradle (Maven 2) proxy repositories (gradle-remote-<key>). Each entry requires url; optional anonymous_access and inline auth block. CI var: TF_VAR_gradle_remote_proxy."
  type        = map(any)

  default = {
    plugins = {
      url              = "https://plugins.gradle.org/m2"
      anonymous_access = true
    }
  }
}

variable "cargo_remote_proxy_auth" {
  description = "Optional upstream auth per cargo proxy repo, e.g. { crates = { username = \"...\", password = \"...\" } }"
  type = map(object({
    username = string
    password = string
    type     = optional(string, "username")
  }))
  default   = {}
  sensitive = true
}

variable "cargo_remote_proxy" {
  description = "Map of Cargo (Rust) proxy repositories (cargo-remote-<key>). Each entry requires url; optional anonymous_access and inline auth block. CI var: TF_VAR_cargo_remote_proxy."
  type        = map(any)

  default = {
    crates = {
      url              = "https://index.crates.io"
      anonymous_access = true
    }
  }
}

variable "apt_remote_proxy_auth" {
  description = "Optional upstream auth per apt proxy repo, e.g. { debian-12 = { username = \"...\", password = \"...\" } }"
  type = map(object({
    username = string
    password = string
    type     = optional(string, "username")
  }))
  default   = {}
  sensitive = true
}

variable "apt_remote_proxy" {
  description = "Map of APT proxy repositories (apt-remote-<key>). Each entry requires url and distribution; optional flat, anonymous_access, and inline auth block. CI var: TF_VAR_apt_remote_proxy."
  type        = map(any)

  default = {
    debian-9 = {
      distribution     = "stretch"
      url              = "http://archive.debian.org/debian"
      anonymous_access = true
    }
    debian-security-9 = {
      distribution     = "stretch/updates"
      url              = "http://security.debian.org/debian-security"
      anonymous_access = true
    }
    debian-10 = {
      distribution     = "buster"
      url              = "http://deb.debian.org/debian"
      anonymous_access = true
    }
    debian-security-10 = {
      distribution     = "buster/updates"
      url              = "http://security.debian.org/debian-security"
      anonymous_access = true
    }
    debian-11 = {
      distribution     = "bullseye"
      url              = "http://deb.debian.org/debian"
      anonymous_access = true
    }
    debian-security-11 = {
      distribution     = "bullseye-security"
      url              = "http://deb.debian.org/debian-security"
      anonymous_access = true
    }
    debian-12 = {
      distribution     = "bookworm"
      url              = "http://deb.debian.org/debian"
      anonymous_access = true
    }
    debian-security-12 = {
      distribution     = "bookworm-security"
      url              = "http://deb.debian.org/debian-security"
      anonymous_access = true
    }
    debian-13 = {
      distribution     = "trixie"
      url              = "http://deb.debian.org/debian"
      anonymous_access = true
    }
    debian-security-13 = {
      distribution     = "trixie-security"
      url              = "http://deb.debian.org/debian-security"
      anonymous_access = true
    }
    astra-18-main = {
      distribution     = "1.8_x86-64"
      url              = "https://download.astralinux.ru/astra/frozen/1.8_x86-64/1.8.1/main-repository"
      anonymous_access = true
    }
    astra-18-extended = {
      distribution     = "1.8_x86-64"
      url              = "https://download.astralinux.ru/astra/frozen/1.8_x86-64/1.8.1/extended-repository"
      anonymous_access = true
    }
    ubuntu-20 = {
      distribution     = "focal"
      url              = "https://archive.ubuntu.com/ubuntu"
      anonymous_access = true
    }
    ubuntu-22 = {
      distribution     = "jammy"
      url              = "https://archive.ubuntu.com/ubuntu"
      anonymous_access = true
    }
    ubuntu-24 = {
      distribution     = "noble"
      url              = "https://archive.ubuntu.com/ubuntu"
      anonymous_access = true
    }
    ubuntu-26 = {
      distribution     = "resolute"
      url              = "https://archive.ubuntu.com/ubuntu"
      anonymous_access = true
    }
    ubuntu-security-20 = {
      distribution     = "focal-security"
      url              = "http://security.ubuntu.com/ubuntu"
      anonymous_access = true
    }
    ubuntu-security-22 = {
      distribution     = "jammy-security"
      url              = "http://security.ubuntu.com/ubuntu"
      anonymous_access = true
    }
    ubuntu-security-24 = {
      distribution     = "noble-security"
      url              = "http://security.ubuntu.com/ubuntu"
      anonymous_access = true
    }
    ubuntu-security-25 = {
      distribution     = "plucky-security"
      url              = "http://security.ubuntu.com/ubuntu"
      anonymous_access = true
    }
    ubuntu-security-26 = {
      distribution     = "resolute-security"
      url              = "http://security.ubuntu.com/ubuntu"
      anonymous_access = true
    }
    docker-debian-9 = {
      distribution     = "stretch"
      url              = "https://download.docker.com/linux/debian"
      anonymous_access = true
    }
    docker-debian-10 = {
      distribution     = "buster"
      url              = "https://download.docker.com/linux/debian"
      anonymous_access = true
    }
    docker-debian-11 = {
      distribution     = "bullseye"
      url              = "https://download.docker.com/linux/debian"
      anonymous_access = true
    }
    docker-debian-12 = {
      distribution     = "bookworm"
      url              = "https://download.docker.com/linux/debian"
      anonymous_access = true
    }
    docker-debian-13 = {
      distribution     = "trixie"
      url              = "https://download.docker.com/linux/debian"
      anonymous_access = true
    }
    docker-ubuntu-20 = {
      distribution     = "focal"
      url              = "https://download.docker.com/linux/ubuntu"
      anonymous_access = true
    }
    docker-ubuntu-22 = {
      distribution     = "jammy"
      url              = "https://download.docker.com/linux/ubuntu"
      anonymous_access = true
    }
    docker-ubuntu-24 = {
      distribution     = "noble"
      url              = "https://download.docker.com/linux/ubuntu"
      anonymous_access = true
    }
    docker-ubuntu-26 = {
      distribution     = "resolute"
      url              = "https://download.docker.com/linux/ubuntu"
      anonymous_access = true
    }
    # PostgreSQL: official APT repository (https://wiki.postgresql.org/wiki/Apt)
    # Client sources.list: deb <nexus-url>/apt-remote-pg-<key> <distribution> main
    pg-debian-11 = {
      distribution     = "bullseye-pgdg"
      url              = "https://apt.postgresql.org/pub/repos/apt/"
      anonymous_access = true
    }
    pg-debian-12 = {
      distribution     = "bookworm-pgdg"
      url              = "https://apt.postgresql.org/pub/repos/apt/"
      anonymous_access = true
    }
    pg-debian-13 = {
      distribution     = "trixie-pgdg"
      url              = "https://apt.postgresql.org/pub/repos/apt/"
      anonymous_access = true
    }
    pg-debian-testing = {
      distribution     = "forky-pgdg"
      url              = "https://apt.postgresql.org/pub/repos/apt/"
      anonymous_access = true
    }
    pg-debian-sid = {
      distribution     = "sid-pgdg"
      url              = "https://apt.postgresql.org/pub/repos/apt/"
      anonymous_access = true
    }
    pg-ubuntu-22 = {
      distribution     = "jammy-pgdg"
      url              = "https://apt.postgresql.org/pub/repos/apt/"
      anonymous_access = true
    }
    pg-ubuntu-24 = {
      distribution     = "noble-pgdg"
      url              = "https://apt.postgresql.org/pub/repos/apt/"
      anonymous_access = true
    }
    pg-ubuntu-25 = {
      distribution     = "questing-pgdg"
      url              = "https://apt.postgresql.org/pub/repos/apt/"
      anonymous_access = true
    }
    pg-ubuntu-26 = {
      distribution     = "resolute-pgdg"
      url              = "https://apt.postgresql.org/pub/repos/apt/"
      anonymous_access = true
    }
  }
}

variable "yum_remote_proxy_auth" {
  description = "Optional upstream auth per yum proxy repo, e.g. { pg-rhel-9 = { username = \"...\", password = \"...\" } }"
  type = map(object({
    username = string
    password = string
    type     = optional(string, "username")
  }))
  default   = {}
  sensitive = true
}

variable "yum_remote_proxy" {
  description = "Map of YUM proxy repositories (yum-remote-<key>). Each entry requires url; optional anonymous_access and inline auth block. CI var: TF_VAR_yum_remote_proxy."
  type        = map(any)

  default = {
    # PostgreSQL: official YUM repository (https://apt.postgresql.org/pub/repos/yum/)
    # Provides RPM packages for RHEL-compatible distributions.
    # URL structure: /pub/repos/yum/<pg-version>/redhat/rhel-<os-ver>-x86_64/
    pg-rhel-8 = {
      url              = "https://apt.postgresql.org/pub/repos/yum/16/redhat/rhel-8-x86_64/"
      anonymous_access = true
    }
    pg-rhel-9 = {
      url              = "https://apt.postgresql.org/pub/repos/yum/16/redhat/rhel-9-x86_64/"
      anonymous_access = true
    }
  }
}

variable "cocoapods_remote_proxy_auth" {
  description = "Optional upstream auth per cocoapods proxy repo, e.g. { cocoapods = { username = \"...\", password = \"...\" } }"
  type = map(object({
    username = string
    password = string
    type     = optional(string, "username")
  }))
  default   = {}
  sensitive = true
}

variable "cocoapods_remote_proxy" {
  description = "Map of CocoaPods proxy repositories (cocoapods-remote-<key>). Each entry requires url; optional anonymous_access and inline auth block. CI var: TF_VAR_cocoapods_remote_proxy."
  type        = map(any)

  default = {
    cocoapods = {
      url              = "https://cdn.cocoapods.org"
      anonymous_access = true
    }
  }
}
# TODO: Composer support is temporarily disabled.
# Re-check provider support later: https://github.com/datadrivers/terraform-provider-nexus/pull/581

variable "conan_remote_proxy_auth" {
  description = "Optional upstream auth per conan proxy repo, e.g. { conancenter = { username = \"...\", password = \"...\" } }"
  type = map(object({
    username = string
    password = string
    type     = optional(string, "username")
  }))
  default   = {}
  sensitive = true
}

variable "conan_remote_proxy" {
  description = "Map of Conan proxy repositories (conan-remote-<key>). Each entry requires url; optional anonymous_access and inline auth block. CI var: TF_VAR_conan_remote_proxy."
  type        = map(any)

  default = {
    conancenter = {
      url              = "https://center2.conan.io"
      anonymous_access = true
    }
  }
}

variable "npm_remote_proxy_auth" {
  description = "Optional upstream auth per npm proxy repo, e.g. { npmjs = { username = \"...\", password = \"...\" } }"
  type = map(object({
    username = string
    password = string
    type     = optional(string, "username")
  }))
  default   = {}
  sensitive = true
}

variable "npm_remote_proxy" {
  description = "Map of NPM proxy repositories (npm-remote-<key>). Each entry requires url; optional anonymous_access and inline auth block. CI var: TF_VAR_npm_remote_proxy."
  type        = map(any)

  default = {
    npmjs = {
      url              = "https://registry.npmjs.org"
      anonymous_access = true
    },
    yarn = {
      url              = "https://registry.yarnpkg.com"
      anonymous_access = true
    }
  }
}

variable "pip_remote_proxy_auth" {
  description = "Optional upstream auth per pip proxy repo, e.g. { pypi = { username = \"...\", password = \"...\" } }"
  type = map(object({
    username = string
    password = string
    type     = optional(string, "username")
  }))
  default   = {}
  sensitive = true
}

variable "pip_remote_proxy" {
  description = "Map of PyPI (pip) proxy repositories (pip-remote-<key>). Each entry requires url; optional anonymous_access and inline auth block. CI var: TF_VAR_pip_remote_proxy."
  type        = map(any)

  default = {
    pypi = {
      url              = "https://pypi.org"
      anonymous_access = true
    }
    huaweicloud = {
      url              = "https://repo.huaweicloud.com"
      anonymous_access = true
    }
  }
}

variable "nuget_remote_proxy_auth" {
  description = "Optional upstream auth per nuget proxy repo, e.g. { nuget = { username = \"...\", password = \"...\" } }"
  type = map(object({
    username = string
    password = string
    type     = optional(string, "username")
  }))
  default   = {}
  sensitive = true
}

variable "nuget_remote_proxy" {
  description = "Map of NuGet proxy repositories (nuget-remote-<key>). Each entry requires url; optional anonymous_access and inline auth block. CI var: TF_VAR_nuget_remote_proxy."
  type        = map(any)

  default = {
    nuget = {
      url              = "https://api.nuget.org/v3/index.json"
      anonymous_access = true
    }
  }
}

variable "go_remote_proxy_auth" {
  description = "Optional upstream auth per go proxy repo, e.g. { go = { username = \"...\", password = \"...\" } }"
  type = map(object({
    username = string
    password = string
    type     = optional(string, "username")
  }))
  default   = {}
  sensitive = true
}

variable "go_remote_proxy" {
  description = "Map of Go module proxy repositories (go-remote-<key>). Each entry requires url; optional anonymous_access and inline auth block. CI var: TF_VAR_go_remote_proxy."
  type        = map(any)

  default = {
    go = {
      url              = "https://proxy.golang.org"
      anonymous_access = true
    }
  }
}

variable "p2_remote_proxy_auth" {
  description = "Optional upstream auth per p2 proxy repo, e.g. { eclipse = { username = \"...\", password = \"...\" } }"
  type = map(object({
    username = string
    password = string
    type     = optional(string, "username")
  }))
  default   = {}
  sensitive = true
}

variable "p2_remote_proxy" {
  description = "Map of Eclipse P2 proxy repositories (p2-remote-<key>). Each entry requires url; optional anonymous_access and inline auth block. CI var: TF_VAR_p2_remote_proxy."
  type        = map(any)

  default = {
    eclipse = {
      url              = "https://download.eclipse.org/releases/latest"
      anonymous_access = true
    }
  }
}

variable "conda_remote_proxy_auth" {
  description = "Optional upstream auth per conda proxy repo, e.g. { forge = { username = \"...\", password = \"...\" } }"
  type = map(object({
    username = string
    password = string
    type     = optional(string, "username")
  }))
  default   = {}
  sensitive = true
}

variable "conda_remote_proxy" {
  description = "Map of Conda proxy repositories (conda-remote-<key>). Each entry requires url; optional anonymous_access and inline auth block. CI var: TF_VAR_conda_remote_proxy."
  type        = map(any)

  default = {
    defaults = {
      url              = "https://repo.anaconda.com/pkgs/main"
      anonymous_access = true
    }
    forge = {
      url              = "https://conda.anaconda.org/conda-forge"
      anonymous_access = true
    }
    nvidia = {
      url              = "https://conda.anaconda.org/nvidia"
      anonymous_access = true
    }
    pytorch = {
      url              = "https://conda.anaconda.org/pytorch"
      anonymous_access = true
    }
    rapidsai = {
      url              = "https://conda.anaconda.org/rapidsai"
      anonymous_access = true
    }
  }
}

variable "raw_remote_proxy_auth" {
  description = "Optional upstream auth per raw proxy repo, e.g. { github = { username = \"...\", password = \"...\" } }"
  type = map(object({
    username = string
    password = string
    type     = optional(string, "username")
  }))
  default   = {}
  sensitive = true
}

variable "raw_remote_proxy" {
  description = "Map of Raw proxy repositories (raw-remote-<key>). Each entry requires url; optional strict_content_type_validation, anonymous_access, and inline auth block. CI var: TF_VAR_raw_remote_proxy."
  type        = map(any)

  default = {
    github = {
      url              = "https://github.com"
      anonymous_access = true
    },
    gradle-bin = {
      url              = "https://services.gradle.org"
      anonymous_access = true
    }
    alpine = {
      url                            = "http://dl-cdn.alpinelinux.org/alpine/"
      anonymous_access               = true
      strict_content_type_validation = false
    }
  }
}

variable "terraform_remote_proxy_auth" {
  description = "Optional upstream auth per Terraform Raw proxy repo, e.g. { hashicorp-binaries = { username = \"...\", password = \"...\" } }"
  type = map(object({
    username = string
    password = string
    type     = optional(string, "username")
  }))
  default   = {}
  sensitive = true
}

variable "terraform_remote_proxy" {
  description = "Map of Terraform Raw proxies (terraform-remote-<key>). An upstream may be either a Provider Network Mirror with its metadata tree or a Terraform CLI binary mirror; the repository does not convert between protocols. Each entry requires url; optional anonymous_access and inline auth block. CI var: TF_VAR_terraform_remote_proxy."
  type        = map(any)

  default = {
    hashicorp-binaries = {
      url              = "https://releases.hashicorp.com/terraform"
      anonymous_access = true
    }
    yandex-providers = {
      url              = "https://terraform-mirror.yandexcloud.net"
      anonymous_access = true
    }
  }
}

variable "r_remote_proxy_auth" {
  description = "Optional upstream auth per r proxy repo, e.g. { cran = { username = \"...\", password = \"...\" } }"
  type = map(object({
    username = string
    password = string
    type     = optional(string, "username")
  }))
  default   = {}
  sensitive = true
}

variable "r_remote_proxy" {
  description = "Map of R (CRAN) proxy repositories (r-remote-<key>). Each entry requires url; optional anonymous_access and inline auth block. CI var: TF_VAR_r_remote_proxy."
  type        = map(any)

  default = {
    cran = {
      url              = "https://cran.r-project.org"
      anonymous_access = true
    }
  }
}

variable "rubygems_remote_proxy_auth" {
  description = "Optional upstream auth per rubygems proxy repo, e.g. { rubygems = { username = \"...\", password = \"...\" } }"
  type = map(object({
    username = string
    password = string
    type     = optional(string, "username")
  }))
  default   = {}
  sensitive = true
}

variable "rubygems_remote_proxy" {
  description = "Map of RubyGems proxy repositories (rubygems-remote-<key>). Each entry requires url; optional anonymous_access and inline auth block. CI var: TF_VAR_rubygems_remote_proxy."
  type        = map(any)

  default = {
    rubygems = {
      url              = "https://rubygems.org"
      anonymous_access = true
    }
  }
}
