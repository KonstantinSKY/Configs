.PHONY: new run

BOTTLE_NAME := MT4-Oanda-Demo
BOTTLES_DIR := $(HOME)/Work/Bottles


new:
	@echo "🍾 Creating bottle $(BOTTLE_NAME) in $(BOTTLES_DIR)..."
	@mkdir -p "$(BOTTLES_DIR)"
	@BOTTLES_PATH="$(BOTTLES_DIR)" bottles-cli new \
		  --bottle-name "$(BOTTLE_NAME)" \
		  --environment application \
		  --arch win32 \
		  --dxvk false --vkd3d false
	@echo "✅ Bottle created."

run:
	@echo "🚀 Installing MT4 into $(BOTTLE_NAME)..."
	@BOTTLES_PATH="$(BOTTLES_DIR)" bottles-cli run -b "$(BOTTLE_NAME)" -e "$(HOME)/Work/Configs/metatrader/oanda4setup.exe"
