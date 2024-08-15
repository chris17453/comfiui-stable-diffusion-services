# Variables
SD_WEBUI_REPO=https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
COMFYUI_REPO=https://github.com/comfyanonymous/ComfyUI.git
APP_SOURCE_DIR=./ai_manager
INSTALL_DIR=/opt/AI
SERVER_NAME=gpu2.watkinslabs.com
SERVICE_USER=ai-manager
SERVICE_GROUP=www-data

.PHONY: all install_services install_sdwebui install_comfyui install_nginx configure_nginx  stop_services enable_sdwebui enable_comfyui disable_services

# Default target: Display help message
help:
	@echo "Usage: make [TARGET]"
	@echo ""
	@echo "Available targets:"
	@echo "  Install:"
	@echo "    install_sdwebui      Install Stable Diffusion Web UI"
	@echo "    install_comfyui      Install ComfyUI"
	@echo "    install_services     Install and configure systemd services"
	@echo "    install_nginx        Install Nginx"
	@echo "    install_ai_manager   install the python web app ai_manager app to the installation directory"
	@echo "    configure_nginx      Configure Nginx"
	@echo "    create_install_dir   Create the installation directory if it doesn't exist"
	@echo "  AI-Manager"
	@echo "    enable_ai_manager    Enable ai_manager on boot (web app for switching)"
	@echo "    disable_ai_manager   Disable the ai_manager service"
	@echo "    start_ai_manager     Start the ai_manager service"
	@echo "    stop_ai_manager      Stop the ai_manager service"
	@echo "  Stable Diffusion "
	@echo "    enable_sdwebui       Enable Stable Diffusion Web UI (and disable ComfyUI)"
	@echo "  ComfyUI "
	@echo "    enable_comfyui       Enable ComfyUI (and disable Stable Diffusion Web UI)"
	@echo "  Global "
	@echo "    disable_services     Disable both sdwebui and comfyui services"
	@echo "    stop_services        Stop all 3 services"
	@echo "    setup_ai_manager     Create the user , group , update sudoers"




# Create the installation directory if it doesn't exist
create_install_dir:
	@if [ ! -d "$(INSTALL_DIR)" ]; then \
		echo "Creating installation directory $(INSTALL_DIR)..."; \
		mkdir -p $(INSTALL_DIR); \
	else \
		echo "Installation directory $(INSTALL_DIR) already exists."; \
	fi


# Copy the ai_manager app to the installation directory
install_ai_manager: create_install_dir
	@echo "Copying ai_manager app to $(INSTALL_DIR)..."
	rsync -av --exclude='venv' $(APP_SOURCE_DIR)/ $(INSTALL_DIR)/ai_manager/
	$(MAKE) setup_ai_manager_venv


# Set up virtual environment for ai_manager and install Flask
setup_ai_manager_venv: create_install_dir
	@echo "Setting up venv for ai_manager..."
	python3 -m venv $(INSTALL_DIR)/ai_manager/venv
	@echo "Installing Flask in ai_manager venv..."
	$(INSTALL_DIR)/ai_manager/venv/bin/pip install Flask gradio 


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
install_services: install_ai_manager
	@echo "Configuring systemd services..."
	sudo cp etc/systemd/system/sdwebui.service /etc/systemd/system/
	sudo cp etc/systemd/system/comfyui.service /etc/systemd/system/
	sudo cp etc/systemd/system/ai_manager.service /etc/systemd/system/
	sudo sed -i "s|INSTALL_DIR|$(INSTALL_DIR)|g" /etc/systemd/system/sdwebui.service
	sudo sed -i "s|INSTALL_DIR|$(INSTALL_DIR)|g" /etc/systemd/system/comfyui.service
	sudo sed -i "s|INSTALL_DIR|$(INSTALL_DIR)|g" /etc/systemd/system/ai_manager.service
	sudo sed -i "s|SERVICE_USER|$(SERVICE_USER)|g" /etc/systemd/system/sdwebui.service
	sudo sed -i "s|SERVICE_USER|$(SERVICE_USER)|g" /etc/systemd/system/comfyui.service
	sudo sed -i "s|SERVICE_USER|$(SERVICE_USER)|g" /etc/systemd/system/ai_manager.service
	sudo sed -i "s|SERVICE_GROUP|$(SERVICE_GROUP)|g" /etc/systemd/system/sdwebui.service
	sudo sed -i "s|SERVICE_GROUP|$(SERVICE_GROUP)|g" /etc/systemd/system/comfyui.service
	sudo sed -i "s|SERVICE_GROUP|$(SERVICE_GROUP)|g" /etc/systemd/system/ai_manager.service
	
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

# Enable ai manager
enable_ai_manager:
	sudo systemctl enable ai_manager.service
	
# Start ai_manager
start_ai_manager:
	@echo "Starting ai_manager service..."
	sudo systemctl start ai_manager.service

# Stop ai_manager 
stop_ai_manager:
	@echo "Starting ai_manager service..."
	sudo systemctl stop ai_manager.service

# Stop ai_manager 
disable_ai_manager:
	@echo "Disabeling ai_manager service..."
	sudo systemctl disable ai_manager.service

# Stop services
stop_services:
	@echo "Stopping ai_manager, sdwebui, and comfyui services..."
	sudo systemctl stop ai_manager.service
	sudo systemctl stop sdwebui.service
	sudo systemctl stop comfyui.service

# Enable Stable Diffusion Web UI
enable_sdwebui: stop_services
	@echo "Enabling sdwebui service and disabling comfyui service..."
	sudo systemctl start sdwebui.service

# Enable ComfyUI 
enable_comfyui: stop_services
	@echo "Enabling comfyui service and disabling sdwebui service..."
	sudo systemctl start comfyui.service

# Disable both sdwebui and comfyui services
disable_services:
	@echo "Disabling both sdwebui and comfyui services..."
	sudo systemctl disable sdwebui.service
	sudo systemctl disable comfyui.service

# Create ai_manager user and add to www-data group
create_ai_manager_user:
	@echo "Creating ai_manager user and adding to www-data group..."
	sudo useradd -m -s /bin/bash ai_manager || echo "User ai_manager already exists."
	sudo usermod -aG www-data ai_manager
	@echo "User ai_manager created and added to www-data group."

# Update sudoers file to allow ai_manager to run necessary commands without a password
update_sudoers:
	@echo "Updating sudoers file..."
	@echo "ai_manager ALL=(ALL) NOPASSWD: /bin/systemctl start comfyui.service, /bin/systemctl start sdwebui.service, /bin/systemctl is-active" | sudo EDITOR='tee -a' visudo
	@echo "Sudoers file updated successfully."

# Combined target to create the user and update sudoers
setup_ai_manager_user: create_ai_manager_user update_sudoers
	@echo "ai_manager user setup complete."



setup: install_services configure_nginx