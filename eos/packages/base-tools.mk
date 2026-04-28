.PHONY: install-base-tools base-tools

BASE_TOOLS = \
	base-devel \
	fzf \
	git \
	github-cli \
	curl \
	wget \
	jq \
	rsync \
	zip \
	unzip \
	man-db \
	man-pages \
	file \
	which \
	lsof \
	nmap \
	ripgrep \
	bat \
	tmux \
	tree \
	alsa-utils \
	pacman-contrib \
	pamac-aur

install-base-tools base-tools: ## Install base command-line and desktop tools
	@$(MAKE) -s -f $(THIS_MAKEFILE) update
	@yay -S --needed --noconfirm $(BASE_TOOLS)
