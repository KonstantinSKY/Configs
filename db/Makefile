# Databases installer Makefile (Manjaro / Arch)
# Installs PostgreSQL stack and DBeaver via your Manjaro Makefile.
# Aliases are inline on each rule. Versions are printed via binaries only.

.PHONY: help h installall ia all postgres p PG client c dbeaver d pg_setup pgset pg_enable pgen pg_start pgst pg_status pgss

MANJARO_MAKEFILE := $(HOME)/Configs/manjaro/Makefile
DB_APP_ID := io.dbeaver.DBeaverCommunity

help h:
	@echo "Targets:"
	@echo "  installall | ia        - Install PostgreSQL (+libs) and DBeaver"
	@echo "  postgres   | p | PG    - Install PostgreSQL server + psql + libpq"
	@echo "  client     | c         - Install PostgreSQL client libs (libpq)"
	@echo "  dbeaver    | d         - Install DBeaver (CE)"
	@echo "  pg_setup   | pgset     - Init cluster (if needed), enable+start"
	@echo "  pg_enable  | pgen      - systemctl enable postgresql"
	@echo "  pg_start   | pgst      - systemctl start postgresql"
	@echo "  pg_status  | pgss      - Show postgresql service status"

# Aggregate installer
all: installall
installall ia:
	@echo "📦 Installing all database tools..."
	@$(MAKE) postgres
	@$(MAKE) dbeaver
	@echo "---------------------------------------------------------------------------------------"
	@echo "✅ Done."

# PostgreSQL install (inline aliases)
postgres p PG:
	@echo "🐘 Installing PostgreSQL (server + psql + libs)..."
	@$(MAKE) -f $(MANJARO_MAKEFILE) install postgresql postgresql-libs
	@echo "🔎 Versions:"
	@which psql >/dev/null 2>&1 && psql --version || echo "psql: not installed"
	@which pg_config >/dev/null 2>&1 && pg_config --version || echo "pg_config: not installed"
	@echo "---------------------------------------------------------------------------------------"

# Client libs only (inline aliases)
client c:
	@echo "📚 Installing PostgreSQL client libs (libpq)…"
	@$(MAKE) -f $(MANJARO_MAKEFILE) install postgresql-libs
	@echo "🔎 Versions:"
	@which pg_config >/dev/null 2>&1 && pg_config --version || echo "pg_config: not installed"
	@echo "---------------------------------------------------------------------------------------"

# DBeaver (inline aliases)
dbeaver d:
	@echo "🦫 Installing DBeaver…"
	flatpak install -y flathub $(DB_APP_ID)
	flatpak override --user --env=GTK_THEME=Adwaita:dark io.dbeaver.DBeaverCommunity
	@echo "🔎 Version (flat):"
	flatpak list | grep -i dbeaver
	@echo "---------------------------------------------------------------------------------------"
	@echo "🔗 Creating CLI wrapper → $(HOME)/.local/bin/dbeaver"
	install -d "$(HOME)/.local/bin"
	@printf '#!/usr/bin/env bash\nexec flatpak run %s "$$@"\n' "$(DB_APP_ID)" > "$(HOME)/.local/bin/dbeaver"
	chmod +x "$(HOME)/.local/bin/dbeaver"
	cat $(HOME)/.local/bin/dbeaver
	@rm -f "$(HOME)/.cache/dmenu_run" 2>/dev/null || true
	@echo "---------------------------------------------------------------------------------------"


# PostgreSQL service helpers (inline aliases)
pg_setup pgset:
	@echo "🗄  Checking Postgres data dir..."
	@if [ ! -d /var/lib/postgres/data/base ]; then \
		echo "📁 Initializing cluster at /var/lib/postgres/data ..."; \
		sudo -iu postgres initdb -D /var/lib/postgres/data >/dev/null; \
	else \
		echo "✅ Cluster already initialized."; \
	fi
	@$(MAKE) pg_enable
	@$(MAKE) pg_start
	@$(MAKE) pg_status
	@echo "---------------------------------------------------------------------------------------"

pg_enable pgen:
	@echo "🔧 Enabling postgresql service..."
	@sudo systemctl enable postgresql
	@echo "---------------------------------------------------------------------------------------"

pg_start pgst:
	@echo "🚀 Starting postgresql service..."
	@sudo systemctl start postgresql || true
	@echo "---------------------------------------------------------------------------------------"

pg_status pgss:
	@echo "📊 postgresql status:"
	@systemctl --no-pager status postgresql || true
	@echo "---------------------------------------------------------------------------------------"
