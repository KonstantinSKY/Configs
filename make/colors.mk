# Global Console Colors for GNU Make
# Included via all.mk

# --- Basic Colors ---
C_BLACK   := $(shell echo -e "\033[0;30m")
C_RED     := $(shell echo -e "\033[0;31m")
C_GREEN   := $(shell echo -e "\033[0;32m")
C_YELLOW  := $(shell echo -e "\033[0;33m")
C_BLUE    := $(shell echo -e "\033[0;34m")
C_VIOLET  := $(shell echo -e "\033[0;35m")
C_CYAN    := $(shell echo -e "\033[0;36m")
C_WHITE   := $(shell echo -e "\033[0;37m")

# --- Bold Colors ---
C_B_BLACK   := $(shell echo -e "\033[1;30m")
C_B_RED     := $(shell echo -e "\033[1;31m")
C_B_GREEN   := $(shell echo -e "\033[1;32m")
C_B_YELLOW  := $(shell echo -e "\033[1;33m")
C_B_BLUE    := $(shell echo -e "\033[1;34m")
C_B_VIOLET  := $(shell echo -e "\033[1;35m")
C_B_CYAN    := $(shell echo -e "\033[1;36m")
C_B_WHITE   := $(shell echo -e "\033[1;37m")

# --- Special ---
C_NC      := $(shell echo -e "\033[0m") # No Color (Reset)

# --- Test Target ---
.PHONY: test-colors

test-colors: ## Show all available global Make colors
	@echo "--- Basic Colors ---"
	@echo -e "${C_BLACK}C_BLACK${C_NC}   - Standard Black"
	@echo -e "${C_RED}C_RED${C_NC}     - Standard Red (Errors, Failures)"
	@echo -e "${C_GREEN}C_GREEN${C_NC}   - Standard Green (Success, OK)"
	@echo -e "${C_YELLOW}C_YELLOW${C_NC}  - Standard Yellow (Warnings, Info)"
	@echo -e "${C_BLUE}C_BLUE${C_NC}    - Standard Blue (Headers, Steps)"
	@echo -e "${C_VIOLET}C_VIOLET${C_NC}  - Standard Violet (Special items)"
	@echo -e "${C_CYAN}C_CYAN${C_NC}    - Standard Cyan (Paths, Links)"
	@echo -e "${C_WHITE}C_WHITE${C_NC}   - Standard White"
	@echo ""
	@echo "--- Bold Colors ---"
	@echo -e "${C_B_BLACK}C_B_BLACK${C_NC}  - Bold Black"
	@echo -e "${C_B_RED}C_B_RED${C_NC}    - Bold Red"
	@echo -e "${C_B_GREEN}C_B_GREEN${C_NC}  - Bold Green"
	@echo -e "${C_B_YELLOW}C_B_YELLOW${C_NC} - Bold Yellow"
	@echo -e "${C_B_BLUE}C_B_BLUE${C_NC}   - Bold Blue"
	@echo -e "${C_B_VIOLET}C_B_VIOLET${C_NC} - Bold Violet"
	@echo -e "${C_B_CYAN}C_B_CYAN${C_NC}   - Bold Cyan"
	@echo -e "${C_B_WHITE}C_B_WHITE${C_NC}  - Bold White"
	@echo ""
	@echo "--- Reset ---"
	@echo -e "Use \$${C_NC} at the end of every colored string to reset."
