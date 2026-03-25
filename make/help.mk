.DEFAULT_GOAL := help
.PHONY: help h

help h: ## Show available commands
	@echo "Available commands:"
	@awk '\
		BEGIN { OFS=""; } \
		/^[a-zA-Z0-9_-][a-zA-Z0-9_.-]*([[:space:]][a-zA-Z0-9_-][a-zA-Z0-9_.-]*)*:[^=]*##[[:space:]]+/ { \
			n = split($$0, parts, ":"); \
			left = parts[1]; \
			desc = $$0; sub(/^[^#]*##[[:space:]]*/, "", desc); \
			split(left, names, /[[:space:]]+/); \
			key_str = ""; \
			for (i in names) { \
				if (names[i] != "" && names[i] !~ /^[%\\.]/) { \
					if (key_str != "") key_str = key_str ", "; \
					key_str = key_str names[i]; \
				} \
			} \
			if (key_str != "") out[key_str] = desc; \
			next; \
		} \
		/^[a-zA-Z0-9_-][a-zA-Z0-9_.-]*([[:space:]][a-zA-Z0-9_-][a-zA-Z0-9_.-]*)*:[^=]*$$/ { \
			n = split($$0, parts, ":"); \
			left = parts[1]; \
			split(left, names, /[[:space:]]+/); \
			key_str = ""; \
			for (i in names) { \
				if (names[i] != "" && names[i] !~ /^[%\\.]/) { \
					if (key_str != "") key_str = key_str ", "; \
					key_str = key_str names[i]; \
				} \
			} \
			if (key_str != "" && !(key_str in out)) out[key_str] = "(no description)"; \
		} \
		END { \
			for (k in out) printf "  %-20s %s\n", k, out[k]; \
		}' $(MAKEFILE_LIST) | sort
