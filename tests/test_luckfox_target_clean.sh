#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_root="$(mktemp -d /tmp/gar-luckfox-clean-test.XXXXXX)"
trap 'rm -rf -- "$test_root"' EXIT

bundle="${test_root}/from-codespace"
mkdir -p "${bundle}/files/gar-servo-pet"
printf 'generated Lyra payload\n' >"${bundle}/files/gar-servo-pet/run"
cp "${repo_root}/config/artifact.json" \
  "${bundle}/artifact.json"

make -C "$repo_root" clean ARTIFACT_ROOT="$bundle" >/dev/null
test ! -e "$bundle"

# Cleanup must not remove an artifact not owned by this repository.
mkdir -p "${bundle}/files/gar-servo-pet"
printf 'preserve foreign payload\n' >"${bundle}/files/gar-servo-pet/run"
cp "${repo_root}/config/artifact.json" "${bundle}/artifact.json"
python3 - "${bundle}/artifact.json" <<'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
manifest = json.loads(path.read_text(encoding="utf-8"))
manifest["target"] = "foreign-target"
path.write_text(json.dumps(manifest), encoding="utf-8")
PY
before="$(sha256sum "${bundle}/artifact.json" "${bundle}/files/gar-servo-pet/run")"
make -C "$repo_root" clean ARTIFACT_ROOT="$bundle" >/dev/null
after="$(sha256sum "${bundle}/artifact.json" "${bundle}/files/gar-servo-pet/run")"
test "$before" = "$after"

echo "test_luckfox_target_clean: OK"
