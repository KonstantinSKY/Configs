# Project build Makefile — self-contained, committed WITH the project repo.
# Installed by `make rust`. No dependency on ~/Work/Configs, so it stays portable.
# Add project-specific targets freely below.

.DEFAULT_GOAL := help
.PHONY: help h build b test t run r fmt clippy check crate cr

MAKEFLAGS += --no-print-directory

ARG_GOALS := crate cr
EXTRA_GOALS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

help h: ## Show available commands
	@grep -hE '^[a-zA-Z][a-zA-Z0-9_ -]*:.*##' $(MAKEFILE_LIST) \
		| awk 'BEGIN{FS=":.*## "}{printf "  %-12s %s\n", $$1, $$2}' | sort

build b: ## cargo build (whole workspace)
	cargo build

test t: ## cargo test (whole workspace)
	cargo test

run r: ## cargo run
	cargo run

fmt: ## cargo fmt
	cargo fmt

clippy: ## cargo clippy (all targets, warnings as errors)
	cargo clippy --all-targets -- -D warnings

check: ## fmt --check + clippy + test
	cargo fmt --check && cargo clippy --all-targets -- -D warnings && cargo test

crate cr: ## Add a crate: make crate <name>   (binary: make crate <name> BIN=1)
	@set -e; \
	name="$(word 2,$(MAKECMDGOALS))"; \
	if [ -z "$${name//[[:space:]]/}" ]; then echo "❌ Crate name required: make crate <name>"; exit 1; fi; \
	if [ -e "crates/$$name" ]; then echo "❌ crates/$$name already exists."; exit 1; fi; \
	cargo new --vcs none $(if $(BIN),,--lib) "crates/$$name"; \
	sed -i 's/^version = .*/version.workspace = true/; s/^edition = .*/edition.workspace = true/' "crates/$$name/Cargo.toml"; \
	echo "✅ Added → crates/$$name"

ifneq ($(filter $(firstword $(MAKECMDGOALS)),$(ARG_GOALS)),)
$(EXTRA_GOALS):
	@:
endif
