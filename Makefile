# Variables
INSTALL_DIR=/opt/AI/
SD_WEBUI_REPO=https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
COMFYUI_REPO=https://github.com/comfyanonymous/ComfyUI.git
SERVER_NAME=gpu2.watkinslabs.com
APP_SOURCE_DIR=./ai_manager

.PHONY: all install_services install_sdwebui install_comfyui install_nginx configure_nginx start_services stop_services enable_sdwebui enable_comfyui disable_services

# Default target: Display help message
help:
	@echo "Usage: make [TARGET]"
	@echo ""
	@echo "Available targets:"
	@echo "  install_sdwebui      Install Stable Diffusion Web UI"
	@echo "  install_comfyui      Install ComfyUI"
	@echo "  install_services     Install and configure systemd services"
	@echo "  install_nginx        Install Nginx"
	@echo "  configure_nginx      Configure Nginx"
	@echo "  start_services       Start all services"
	@echo "  stop_services        Stop all services"
	@echo "  enable_sdwebui       Enable Stable Diffusion Web UI (and disable ComfyUI)"
	@echo "  enable_comfyui       Enable ComfyUI (and disable Stable Diffusion Web UI)"
	@echo "  disable_services     Disable both sdwebui and comfyui services"
	@echo "  copy_app             Copy the ai_manager app to the installation directory"
	@echo "  create_install_dir   Create the installation directory if it doesn't exist"


# Create the installation directory if it doesn't exist
create_install_dir:
	@if [ ! -d "$(INSTALL_DIR)" ]; then \
		echo "Creating installation directory $(INSTALL_DIR)..."; \
		mkdir -p $(INSTALL_DIR); \
	else \
		echo "Installation directory $(INSTALL_DIR) already exists."; \
	fi


# Copy the ai_manager app to the installation directory
copy_app: create_install_dir
	@echo "Copying ai_manager app to $(INSTALL_DIR)..."
	rsync -av --exclude='venv' $(APP_SOURCE_DIR)/ $(INSTALL_DIR)/ai_manager/


# Install Stable Diffusion Web UI
install_sdwebui: create_install_dir
	@echo "Cloning Stable Diffusion Web UI..."
	git clone $(SD_WEBUI_REPO) $(INSTALL_DIR)/stable-diffusion-webui
	@echo "Setting up venv for Stable Diffusion Web UI..."
	cd $(INSTALL_DIR)/stable-diffusion-webui && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt && deactivate

# Install ComfyUI
install_comfyui: create_install_dir
	@echo "Cloning ComfyUI..."
	git clone $(COMFYUI_REPO) $(INSTALL_DIR)/comfyui
	@echo "Setting up venv for ComfyUI..."
	cd $(INSTALL_DIR)/comfyui && python3 -m venv venv && source venv/bin/activate && pip install -r requirements.txt && deactivate

# Install and configure services
install_services: copy_app
	@echo "Configuring systemd services..."
	sudo cp etc/systemd/system/sdwebui.service /etc/systemd/system/
	sudo cp etc/systemd/system/comfyui.service /etc/systemd/system/
	sudo cp etc/systemd/system/ai_manager.service /etc/systemd/system/
	sudo sed -i "s|INSTALL_DIR|$(INSTALL_DIR)|g" /etc/systemd/system/sdwebui.service
	sudo sed -i "s|INSTALL_DIR|$(INSTALL_DIR)|g" /etc/systemd/system/comfyui.service
	sudo sed -i "s|INSTALL_DIR|$(INSTALL_DIR)|g" /etc/systemd/system/ai_manager.service
	sudo systemctl daemon-reload

# Install Nginx
install_nginx:
	@echo "Installing Nginx..."
	sudo apt update
	sudo apt install -y nginx

# Configure Nginx
configure_nginx:
	@echo "Checking if Nginx configuration exists..."
	@if [ -f /etc/nginx/nginx.conf ]; then \
		echo "Backing up existing Nginx configuration..."; \
		sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak; \
	else \
		echo "Nginx configuration not found, skipping backup."; \
	fi
	@echo "Configuring Nginx..."
	sudo cp etc/nginx/nginx.conf /etc/nginx/nginx.conf
	sudo sed -i "s|SERVER_NAME|$(SERVER_NAME)|g" /etc/nginx/nginx.conf
	@echo "Testing Nginx configuration..."
	sudo nginx -t
	@if [ $$? -eq 0 ]; then \
		echo "Restarting Nginx..."; \
		sudo systemctl restart nginx; \
		echo "Nginx configuration applied successfully."; \
	else \
		echo "Nginx configuration test failed. Restoring previous configuration."; \
		if [ -f /etc/nginx/nginx.conf.bak ]; then \
			sudo cp /etc/nginx/nginx.conf.bak /etc/nginx/nginx.conf; \
			sudo systemctl restart nginx; \
			echo "Restored previous Nginx configuration."; \
		else \
			echo "Backup not found, cannot restore previous configuration."; \
		fi \
	fi

# Start services
start_services:
	@echo "Starting ai_manager service..."
	sudo systemctl start ai_manager.service

# Stop services
stop_services:
	@echo "Stopping ai_manager, sdwebui, and comfyui services..."
	sudo systemctl stop ai_manager.service
	sudo systemctl stop sdwebui.service
	sudo systemctl stop comfyui.service

# Enable Stable Diffusion Web UI (and disable ComfyUI)
enable_sdwebui: stop_services
	@echo "Enabling sdwebui service and disabling comfyui service..."
	sudo systemctl disable comfyui.service
	sudo systemctl enable sdwebui.service
	sudo systemctl start sdwebui.service
	sudo systemctl enable ai_manager.service

# Enable ComfyUI (and disable Stable Diffusion Web UI)
enable_comfyui: stop_services
	@echo "Enabling comfyui service and disabling sdwebui service..."
	sudo systemctl disable sdwebui.service
	sudo systemctl enable comfyui.service
	sudo systemctl start comfyui.service
	sudo systemctl enable ai_manager.service

# Disable both sdwebui and comfyui services
disable_services:
	@echo "Disabling both sdwebui and comfyui services..."
	sudo systemctl disable sdwebui.service
	sudo systemctl disable comfyui.service
