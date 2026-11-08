#!/usr/bin/env bash
set -euo pipefail
export TF_PLUGIN_CACHE_DIR="${TF_PLUGIN_CACHE_DIR:-${TMPDIR:-/tmp}/ha-terraform-provider-cache}"
mkdir -p "$TF_PLUGIN_CACHE_DIR"
terraform fmt -check -recursive
for dir in modules/network modules/service modules/telemetry modules/state-backend bootstrap environments/dev environments/production; do
  terraform -chdir="$dir" init -backend=false -input=false
  terraform -chdir="$dir" validate -no-color
done
for dir in modules/network modules/service modules/state-backend; do
  terraform -chdir="$dir" test -no-color
done
python3 -m unittest discover -s scripts -v
