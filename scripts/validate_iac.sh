#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
mode=${1:-all}

roots='environments/nonprod-proxy
modules/productspace-repositories'

run_tflint() {
  command -v tflint >/dev/null || {
    echo "tflint is required" >&2
    return 2
  }

  printf '%s\n' "$roots" | while IFS= read -r root; do
    test -n "$root" || continue
    echo "TFLint: $root"
    tflint --chdir="$repo_dir/$root" \
      --config="$repo_dir/.tflint.hcl" \
      --format=compact \
      --minimum-failure-severity=warning
  done
}

run_trivy() {
  command -v trivy >/dev/null || {
    echo "trivy is required" >&2
    return 2
  }

  printf '%s\n' "$roots" | while IFS= read -r root; do
    test -n "$root" || continue
    echo "Trivy config: $root"
    trivy config \
      --skip-check-update \
      --exit-code 1 \
      --severity HIGH,CRITICAL \
      --ignorefile "$repo_dir/.trivyignore.yaml" \
      "$repo_dir/$root"
  done
}

case "$mode" in
  all)
    run_tflint
    run_trivy
    ;;
  lint)
    run_tflint
    ;;
  security)
    run_trivy
    ;;
  *)
    echo "usage: $0 [all|lint|security]" >&2
    exit 2
    ;;
esac
