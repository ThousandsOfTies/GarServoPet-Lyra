# Gapless Agent Runtime build environment.

PRODUCT_BUILD_SCRIPT ?= scripts/product-build.sh
PRODUCT_ARTIFACTS_SCRIPT ?= scripts/product-artifacts.sh
PRODUCT_CLEAN_SCRIPT ?= scripts/product-target-build.sh

ARTIFACT_ROOT ?= artifacts/from-codespace
BUILD_IMAGE ?= gar-build-env:latest

.PHONY: all setup sync build artifacts check clean

all: artifacts

setup:
	scripts/setup-product-branch.sh

sync:
	@if [ -f .gitmodules ]; then \
		git submodule foreach --recursive 'branch=$$(git branch --show-current); if [ -n "$$branch" ]; then git pull --ff-only; else echo "detached HEAD; skip pull"; fi'; \
	fi

build:
	@if [ -x "$(PRODUCT_BUILD_SCRIPT)" ]; then \
		"$(PRODUCT_BUILD_SCRIPT)"; \
	else \
		echo "No product build script: $(PRODUCT_BUILD_SCRIPT)"; \
	fi

artifacts: build
	@if [ -x "$(PRODUCT_ARTIFACTS_SCRIPT)" ]; then \
		"$(PRODUCT_ARTIFACTS_SCRIPT)" "$(ARTIFACT_ROOT)"; \
	else \
		echo "No product artifacts script: $(PRODUCT_ARTIFACTS_SCRIPT)"; \
	fi

check:
	bash -n scripts/*.sh scripts/target/package.sh config/luckfox-rk3506.env.example
	sh -n scripts/target/configure-target scripts/target/health
	python3 -m json.tool config/artifact.json >/dev/null
	python3 -m json.tool hardware/binding.json >/dev/null
	python3 -m json.tool sources/gar-servo-pet/app.json >/dev/null
	PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s tests -p 'test_*.py' -v
	node --test tests/servo-model.test.mjs
	tests/test_luckfox_target_clean.sh
	@if command -v cc >/dev/null 2>&1; then \
		$(MAKE) -C sources/gar-servo-pet check; \
	elif command -v docker >/dev/null 2>&1 && \
	     docker image inspect "$(BUILD_IMAGE)" >/dev/null 2>&1; then \
		docker run --rm --pull=never \
			--user "$$(id -u):$$(id -g)" \
			-v "$(CURDIR):/workspace" \
			-w /workspace/sources/gar-servo-pet \
			"$(BUILD_IMAGE)" make check; \
	else \
		echo "No host C compiler and no local $(BUILD_IMAGE) fallback" >&2; \
		exit 1; \
	fi
	sources/gar-servo-pet/build/host/gar-servoctl \
		--i2c-config hardware/i2c.csv \
		--servo-config hardware/servo-calibration.csv validate

clean:
	@if [ -x "$(PRODUCT_CLEAN_SCRIPT)" ]; then \
		GAR_ARTIFACT_ROOT="$(ARTIFACT_ROOT)" \
			"$(PRODUCT_CLEAN_SCRIPT)" clean; \
	fi
