terraform {
  required_providers {
    # Compatibility contract for this root: provider 3.0.0 and the current
    # Docker configuration are used as one tested set. Because
    # path_based_routing was added to the Nexus API in 3.83.0, this root must
    # not target Nexus Repository versions older than 3.83.0.
    nexus = {
      source  = "datadrivers/nexus"
      version = "3.0.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "nexus" {
  insecure = var.nexus_insecure
}
