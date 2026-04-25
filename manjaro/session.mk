# was: .PHONY: xprofile xp mimeapps ma picom         # xprofile/xp moved out to xprofile/Makefile
.PHONY: mimeapps ma picom

# was: TARGET_XPROFILE_FILE = $(HOME)/.xprofile      # moved to xprofile/Makefile
# was: XPROFILE_SOURCE_FILE = $(THIS_DIR)/xprofile/.xprofile  # moved
TARGET_MIMEAPPS_FILE = $(HOME)/.config/mimeapps.list
MIMEAPPS_SOURCE_FILE = $(THIS_DIR)/mimeapps.list

PICOM_MAKEFILE := $(CONFIGS_DIR)/picom/Makefile

## ---------------------------
## 👤 User Session
## ---------------------------
picom: ## Install picom compositor and link config
	@$(MAKE) -s -f $(PICOM_MAKEFILE) install

# was: xprofile xp: ## Link .xprofile via a direct symlink   # moved to xprofile/Makefile (link target)
# was: 	@$(call link,$(XPROFILE_SOURCE_FILE),$(TARGET_XPROFILE_FILE))

mimeapps ma: ## Link managed XDG default applications file
	@$(call link,$(MIMEAPPS_SOURCE_FILE),$(TARGET_MIMEAPPS_FILE))
