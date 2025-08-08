.PHONY: help install run clean remove_old

# === Configuration ===
MT4_URL := https://download.mql5.com/cdn/web/metaquotes.software/mt4/mt4setup.exe
MT4_INSTALLER := mt4setup.exe
CONFIG_DIR := ~/Configs/manjaro/Makefile

# === Help ===
help:
	@echo "📌 Available targets:"
	@echo "  make install     – Установить PlayOnLinux и скачать свежий MetaTrader 4"
	@echo "  make run         – Запустить MT4 через PlayOnLinux"
	@echo "  make clean       – Удалить установщик MT4"
	@echo "  make remove_old  – Удалить старые Wine-префиксы и каталоги"

# === Install PlayOnLinux and download MT4 ===
install:
	@echo "🔄 Обновление системы через $(CONFIG_DIR)..."
	$(MAKE) -f $(CONFIG_DIR) update

	@echo "📦 Установка PlayOnLinux через yay..."
	yay -S --noconfirm playonlinux wget

	@echo "⬇️ Загрузка последнего установщика MetaTrader 4..."
	wget -O $(MT4_INSTALLER) $(MT4_URL)

	@echo "📂 Установка MetaTrader 4 вручную:"
	@echo "1. Открой PlayOnLinux."
	@echo "2. Нажми 'Установить', выбери 'Установить программу не из списка'."
	@echo "3. Укажи путь к $(MT4_INSTALLER)."
	@echo "4. Установи в 32-битном префиксе, выбрав Windows 10."
	@echo "✅ После установки можешь использовать 'make run' для запуска MT4."

# === Run MT4 through PlayOnLinux ===
run:
	@echo "🚀 Попытка запустить MT4 через PlayOnLinux..."
	playonlinux --run "MetaTrader 4" || echo "❌ Убедись, что MetaTrader 4 установлен в PlayOnLinux."

# === Cleanup ===
clean:
	@echo "🧹 Удаление установщика MT4..."
	rm -f $(MT4_INSTALLER)

# === Remove old Wine setups ===
remove_old:
	@echo "❌ Удаление старых Wine-префиксов и установок MT4..."
	rm -rf ~/.wine_mt4 ~/.mt4 ~/.PlayOnLinux
	rm -f ~/mt4setup.exe ~/MT4/setup.exe
