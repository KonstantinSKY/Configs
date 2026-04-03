.PHONY: \
	help \
	bluetooth-setup setup \
	install-bluetooth \
	enable-bluetooth \
	configure-bluetooth \
	bluetooth-open open \
	bluetooth-close close \
	bluetooth-status status s \
	bluetooth-logs logs \
	bluetooth-sco-log \
	bluetooth-sco-since \
	bluetooth-devices devices d \
	bluetooth-info info \
	bluetooth-pair pair \
	bluetooth-trust trust \
	bluetooth-connect connect c \
	bluetooth-disconnect disconnect dc \
	bluetooth-a2dp a2dp \
	bluetooth-headset headset hfp \
	bluetooth-audio-status audio
.DEFAULT_GOAL := help

THIS_MAKEFILE := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_DIR := $(patsubst %/,%,$(dir $(THIS_MAKEFILE)))
CONFIGS_ROOT := $(abspath $(THIS_DIR)/../..)
HELP_MAKEFILE := $(CONFIGS_ROOT)/make/help.mk

ifeq ($(filter $(HELP_MAKEFILE),$(MAKEFILE_LIST)),)
include $(HELP_MAKEFILE)
endif

BLUETOOTH_PACKAGES = \
	bluez \
	bluez-utils \
	blueman

BLUETOOTH_SERVICE := bluetooth.service
BLUETOOTH_MAIN_CONF := /etc/bluetooth/main.conf
BT_DEVICE ?=
BT_CARD ?= $(if $(strip $(BT_DEVICE)),bluez_card.$(subst :,_,$(BT_DEVICE)),)
BT_A2DP_PROFILE ?= a2dp-sink
BT_HEADSET_PROFILE ?= headset-head-unit
BT_LOG_LINES ?= 80
SINCE ?= 10 minutes ago

require_bt_device = \
	if [ -z "$(strip $(BT_DEVICE))" ]; then \
		echo '❌ BT_DEVICE is required. Usage: make bluetooth-info BT_DEVICE=AA:BB:CC:DD:EE:FF'; \
		exit 1; \
	fi

require_bt_card = \
	if [ -z "$(strip $(BT_CARD))" ]; then \
		echo '❌ BT_CARD is required. Set BT_DEVICE=AA:BB:CC:DD:EE:FF or BT_CARD=bluez_card.AA_BB_CC_DD_EE_FF'; \
		exit 1; \
	fi

bluetooth-setup setup: ## Install Bluetooth packages, enable the service, and set basic defaults
	@$(MAKE) -s -f $(THIS_MAKEFILE) install-bluetooth
	@$(MAKE) -s -f $(THIS_MAKEFILE) enable-bluetooth
	@$(MAKE) -s -f $(THIS_MAKEFILE) configure-bluetooth

install-bluetooth: ## Install the managed Bluetooth package set
	@echo "📦 Installing Bluetooth packages..."
	@sudo pacman -S --needed --noconfirm $(BLUETOOTH_PACKAGES)
	@echo "✅ Bluetooth packages are installed."
	@echo "-------------------------------------------------------------------------------"

enable-bluetooth: ## Enable and start bluetooth.service
	@echo "🔵 Enabling Bluetooth service..."
	@sudo systemctl enable --now $(BLUETOOTH_SERVICE)
	@sudo systemctl is-active $(BLUETOOTH_SERVICE)
	@echo "-------------------------------------------------------------------------------"

configure-bluetooth: ## Set AutoEnable=true in /etc/bluetooth/main.conf and restart Bluetooth
	@if [ ! -e "$(BLUETOOTH_MAIN_CONF)" ]; then \
		echo "❌ Bluetooth main.conf not found: $(BLUETOOTH_MAIN_CONF)"; \
		exit 1; \
	fi
	@echo "⚙️  Configuring Bluetooth defaults in $(BLUETOOTH_MAIN_CONF)..."
	@tmp="$$(mktemp)"; \
	awk '\
		BEGIN { seen_policy=0; in_policy=0; done=0 } \
		/^\[Policy\]$$/ { seen_policy=1; in_policy=1; print; next } \
		/^\[.*\]$$/ { \
			if (in_policy && !done) { print "AutoEnable=true"; done=1 } \
			in_policy=0; \
			print; \
			next \
		} \
		in_policy && /^[#[:space:]]*AutoEnable[[:space:]]*=/ { \
			print "AutoEnable=true"; \
			done=1; \
			next \
		} \
		{ print } \
		END { \
			if (seen_policy && in_policy && !done) { \
				print "AutoEnable=true"; \
			} else if (!seen_policy) { \
				print ""; \
				print "[Policy]"; \
				print "AutoEnable=true"; \
			} \
		}' "$(BLUETOOTH_MAIN_CONF)" > "$$tmp"; \
	sudo install -m 644 "$$tmp" "$(BLUETOOTH_MAIN_CONF)"; \
	rm -f "$$tmp"
	@sudo systemctl restart $(BLUETOOTH_SERVICE)
	@echo "✅ AutoEnable=true is configured."
	@echo "-------------------------------------------------------------------------------"

bluetooth-open open: ## Power on Bluetooth and make the controller pairable/discoverable for pairing
	@echo "🔓 Opening Bluetooth controller for pairing..."
	@bluetoothctl power on
	@bluetoothctl pairable on
	@bluetoothctl discoverable on
	@printf 'agent on\ndefault-agent\nquit\n' | bluetoothctl
	@bluetoothctl show

bluetooth-close close: ## Disable discoverable/pairable mode after pairing
	@echo "🔒 Closing Bluetooth controller pairing mode..."
	@bluetoothctl discoverable off
	@bluetoothctl pairable off
	@bluetoothctl show

bluetooth-status status s: ## Print a concise Bluetooth service/controller summary
	@echo "🔎 Bluetooth service:"
	@systemctl is-enabled $(BLUETOOTH_SERVICE) || true
	@systemctl is-active $(BLUETOOTH_SERVICE) || true
	@echo ""
	@echo "🎛️  Controller:"
	@bluetoothctl show
	@echo ""
	@echo "📱 Known devices:"
	@bluetoothctl devices || true

bluetooth-logs logs: ## Show recent bluetooth.service logs for the current boot
	@journalctl -u $(BLUETOOTH_SERVICE) -b --no-pager -n $(BT_LOG_LINES)

bluetooth-sco-log: ## Show recent SCO-related kernel Bluetooth errors for the current boot
	@journalctl -k -b --no-pager | grep 'Bluetooth: hci0: corrupted SCO packet' | tail -n $(BT_LOG_LINES)

bluetooth-sco-since: ## Show SCO-related kernel Bluetooth errors since a timestamp, e.g. SINCE="2026-04-02 18:24:37"
	@journalctl -k -b --since '$(SINCE)' --no-pager | grep 'Bluetooth: hci0: corrupted SCO packet' || true

bluetooth-devices devices d: ## List Bluetooth devices known to the controller
	@bluetoothctl devices

bluetooth-info info: ## Show Bluetooth details for one device. Usage: make info BT_DEVICE=AA:BB:CC:DD:EE:FF
	@$(require_bt_device)
	@bluetoothctl info $(BT_DEVICE)

bluetooth-pair pair: ## Pair a Bluetooth device. Usage: make pair BT_DEVICE=AA:BB:CC:DD:EE:FF
	@$(require_bt_device)
	@bluetoothctl pair $(BT_DEVICE)

bluetooth-trust trust: ## Trust a Bluetooth device. Usage: make trust BT_DEVICE=AA:BB:CC:DD:EE:FF
	@$(require_bt_device)
	@bluetoothctl trust $(BT_DEVICE)

bluetooth-connect connect c: ## Connect a Bluetooth device. Usage: make connect BT_DEVICE=AA:BB:CC:DD:EE:FF
	@$(require_bt_device)
	@bluetoothctl connect $(BT_DEVICE)

bluetooth-disconnect disconnect dc: ## Disconnect a Bluetooth device. Usage: make disconnect BT_DEVICE=AA:BB:CC:DD:EE:FF
	@$(require_bt_device)
	@bluetoothctl disconnect $(BT_DEVICE)

bluetooth-a2dp a2dp: ## Switch the Bluetooth audio card to A2DP. Usage: make a2dp BT_DEVICE=AA:BB:CC:DD:EE:FF
	@$(require_bt_card)
	@pactl set-card-profile "$(BT_CARD)" "$(BT_A2DP_PROFILE)"
	@echo "✅ $(BT_CARD) -> $(BT_A2DP_PROFILE)"

bluetooth-headset headset hfp: ## Switch the Bluetooth audio card to HFP/HSP. Usage: make headset BT_DEVICE=AA:BB:CC:DD:EE:FF
	@$(require_bt_card)
	@pactl set-card-profile "$(BT_CARD)" "$(BT_HEADSET_PROFILE)"
	@echo "✅ $(BT_CARD) -> $(BT_HEADSET_PROFILE)"

bluetooth-audio-status audio: ## Show current PipeWire/Pulse audio card state for Bluetooth devices
	@pactl list cards short | grep -E 'bluez_card|alsa_card' || true
	@echo ""
	@wpctl status
