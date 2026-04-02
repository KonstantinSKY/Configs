# Global GNU Make extensions
# These files are found because of MAKEFLAGS="-I /home/sky/Work/Configs/make"

MAKE_MODULE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
CONFIGS_DIR := $(abspath $(MAKE_MODULE_DIR)/..)
PRIMARY_MAKEFILE := $(abspath $(firstword $(MAKEFILE_LIST)))

ifneq ($(filter $(CONFIGS_DIR)%,$(PRIMARY_MAKEFILE)),)
include $(MAKE_MODULE_DIR)/colors.mk
include $(MAKE_MODULE_DIR)/fs.mk
include $(MAKE_MODULE_DIR)/link.mk
include $(MAKE_MODULE_DIR)/backup.mk
include $(MAKE_MODULE_DIR)/stow.mk
include $(MAKE_MODULE_DIR)/help.mk
include $(MAKE_MODULE_DIR)/git.mk
include $(MAKE_MODULE_DIR)/update.mk
endif

# Add more global modules here in the future
