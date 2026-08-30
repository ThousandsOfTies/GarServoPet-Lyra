#!/usr/bin/env bash
# Fixed GarServoPet-Lyra build entrypoint. This repository has one application
# and one physical target, so composition is explicit and needs no dispatcher.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "${repo_root}/config/product.env" ]]; then
  # shellcheck disable=SC1091
  source "${repo_root}/config/product.env"
fi

if [[ -n "${GAR_TARGET:-}" && "$GAR_TARGET" != "luckfox-rk3506" ]]; then
  echo "GarServoPet-Lyra has fixed target luckfox-rk3506, not $GAR_TARGET" >&2
  exit 2
fi

export GAR_PRODUCT_ID=gar-servo-pet
export GAR_TARGET=luckfox-rk3506
export GAR_TARGET_ARTIFACT_KIND=ssh-app
export GAR_TARGET_ARTIFACT_MANIFEST="${repo_root}/config/artifact.json"
export GAR_TARGET_DEFAULT_CONFIG="${repo_root}/config/luckfox-rk3506.env.example"
export GAR_TARGET_LOCAL_CONFIG="${repo_root}/config/luckfox-rk3506.env"
export GAR_APP_ID=gar-servo-pet
export GAR_APP_MANIFEST="${repo_root}/sources/gar-servo-pet/app.json"
export GAR_APP_ROOT="${repo_root}/sources/gar-servo-pet"
export GAR_APP_BUILD_GOAL=target-build
export GAR_APP_BINARY="${GAR_APP_ROOT}/build/target/gar-servoctl"
export GAR_APP_BINARY_NAME=gar-servoctl
export GAR_APP_ENTRYPOINT="${GAR_APP_ROOT}/run"
export GAR_APP_ENTRYPOINT_NAME=run
export GAR_APP_README="${GAR_APP_ROOT}/README.md"
export GAR_APP_INSTALL_DIR=/opt/gar/apps/gar-servo-pet
export GAR_APP_I2C_CONFIG_DEST=hardware/i2c.csv
export GAR_APP_CONNECTIONS_CONFIG_DEST=hardware/connections.csv
export GAR_APP_SERVO_CONFIG_DEST=hardware/servo-calibration.csv
export GAR_HARDWARE_BINDING="${repo_root}/hardware/binding.json"
export GAR_RUNTIME_I2C_CONFIG="${repo_root}/hardware/i2c.csv"
export GAR_RUNTIME_CONNECTIONS_CONFIG="${repo_root}/hardware/connections.csv"
export GAR_RUNTIME_SERVO_CONFIG="${repo_root}/hardware/servo-calibration.csv"

exec "${repo_root}/scripts/target/package.sh" "$@"
