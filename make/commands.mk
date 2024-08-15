include ./make/config.mk

# Enable ai manager
enable_ai_manager:
	@systemctl enable ai_manager.service
	
# Start ai_manager
start_ai_manager:
	@echo "Starting ai_manager service..."
	@systemctl start ai_manager.service

# Stop ai_manager 
stop_ai_manager:
	@echo "Starting ai_manager service..."
	@systemctl stop ai_manager.service

# Stop ai_manager 
disable_ai_manager:
	@echo "Disabeling ai_manager service..."
	@systemctl disable ai_manager.service

# Stop services
stop_services:
	@echo "Stopping ai_manager, sdwebui, and comfyui services..."
	@systemctl stop ai_manager.service
	@systemctl stop sdwebui.service
	@systemctl stop comfyui.service

# Enable Stable Diffusion Web UI
enable_sdwebui: stop_services
	@echo "Enabling sdwebui service and disabling comfyui service..."
	@systemctl start sdwebui.service

# Enable ComfyUI 
enable_comfyui: stop_services
	@echo "Enabling comfyui service and disabling sdwebui service..."
	@systemctl start comfyui.service

# Disable both sdwebui and comfyui services
disable_services:
	@echo "Disabling both sdwebui and comfyui services..."
	@systemctl disable sdwebui.service
	@systemctl disable comfyui.service


clear_venv:
	@rm -rf $(INSTALL_DIR)/comfyui/venv
	@rm -rf $(INSTALL_DIR)/stable-diffusion-webui/venv
