.DEFAULT_GOAL := help
.PHONY: help h

h: help ## Short alias for help

help: ## Show available targets
	@echo "Available commands:"
	@awk '\
		BEGIN { OFS=""; } \
		/^[a-zA-Z0-9_-][a-zA-Z0-9_.-]*([[:space:]][a-zA-Z0-9_-][a-zA-Z0-9_.-]*)*:[^=]*##[[:space:]]+/ { \
			n = split($$0, parts, ":"); \
			left = parts[1]; \
			desc = $$0; sub(/^[^#]*##[[:space:]]*/, "", desc); \
			split(left, names, /[[:space:]]+/); \
			for (i in names) if (names[i] != "" && names[i] !~ /^[%\\.]/) { \
				key = names[i]; out[key] = desc; \
			} \
			next; \
		} \
		/^[a-zA-Z0-9_-][a-zA-Z0-9_.-]*([[:space:]][a-zA-Z0-9_-][a-zA-Z0-9_.-]*)*:[^=]*$$/ { \
			n = split($$0, parts, ":"); \
			left = parts[1]; \
			split(left, names, /[[:space:]]+/); \
			for (i in names) if (names[i] != "" && names[i] !~ /^[%\\.]/ && !(names[i] in out)) { \
				out[names[i]] = "(no description)"; \
			} \
		} \
		END { \
			for (k in out) printf "  %-16s %s\n", k, out[k]; \
		}' $(MAKEFILE_LIST) | sort
