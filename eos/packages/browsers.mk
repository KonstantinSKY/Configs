.PHONY: install-browsers browsers

BROWSERS = \
	google-chrome \
	torbrowser-launcher

install-browsers browsers: ## Install managed browsers
	@$(MAKE) -s -f $(THIS_MAKEFILE) update
	@yay -S --needed --noconfirm $(BROWSERS)
