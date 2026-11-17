#!/bin/sh
set -eu

install_dir=${1:-}
test -n "$install_dir" || {
  echo "usage: $0 <install-dir>" >&2
  exit 2
}

tflint_version=0.66.0
tflint_sha256=22be11cadc25cd02401e94c0ccc91aa63467debb8485c2a755d98f4c0a9d1e2e
trivy_version=0.76.2
trivy_sha256=bc0fc726e017b8927a62b2d3531d7a84ee01769daf5c99ed866dced54089fdbf

tflint_base_url=${TFLINT_RELEASE_BASE_URL:-https://github.com/terraform-linters/tflint/releases/download/v${tflint_version}}
trivy_base_url=${TRIVY_RELEASE_BASE_URL:-https://github.com/aquasecurity/trivy/releases/download/v${trivy_version}}

work_dir=$(mktemp -d)
trap 'rm -rf "$work_dir"' EXIT INT TERM
mkdir -p "$install_dir"

curl --fail --silent --show-error --location \
  "$tflint_base_url/tflint_linux_amd64.zip" \
  --output "$work_dir/tflint.zip"
echo "$tflint_sha256  $work_dir/tflint.zip" | sha256sum --check
unzip -q "$work_dir/tflint.zip" -d "$work_dir/tflint"
install -m 0755 "$work_dir/tflint/tflint" "$install_dir/tflint"

curl --fail --silent --show-error --location \
  "$trivy_base_url/trivy_${trivy_version}_Linux-64bit.tar.gz" \
  --output "$work_dir/trivy.tar.gz"
echo "$trivy_sha256  $work_dir/trivy.tar.gz" | sha256sum --check
tar -xzf "$work_dir/trivy.tar.gz" -C "$work_dir" trivy
install -m 0755 "$work_dir/trivy" "$install_dir/trivy"

"$install_dir/tflint" --version
"$install_dir/trivy" --version
