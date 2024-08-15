include ./make/config.mk


# Copy the ai_manager app to the installation directory
install_ai_manager: create_install_dir 
	@echo "Copying ai_manager app to $(INSTALL_DIR)..."
	@rsync -av --exclude='venv' $(APP_SOURCE_DIR)/ $(INSTALL_DIR)/ai_manager/
	@$(MAKE) setup_ai_manager_venv
	@$(MAKE) set_permissions  


# Set up virtual environment for ai_manager and install Flask
setup_ai_manager_venv: create_install_dir
	@echo "Setting up venv for ai_manager..."
	@python3 -m venv $(INSTALL_DIR)/ai_manager/venv
	@echo "Installing Flask in ai_manager venv..."
	$(INSTALL_DIR)/ai_manager/venv/bin/pip install Flask gradio 
	@$(MAKE) set_permissions  


# Install Stable Diffusion Web UI
install_sdwebui: create_install_dir
	@echo "Cloning Stable Diffusion Web UI..."
	@-git clone $(SD_WEBUI_REPO) $(INSTALL_DIR)/stable-diffusion-webui
	@echo "Setting up venv for Stable Diffusion Web UI..."
	@cd $(INSTALL_DIR)/stable-diffusion-webui && python3 -m venv venv
    # Install custom torch first
	@cd $(INSTALL_DIR)/stable-diffusion-webui && source venv/bin/activate && pip install torch torchvision torchaudio xformers --index-url $(CUDA_TORCH)  && deactivate
	@cd $(INSTALL_DIR)/stable-diffusion-webui && source venv/bin/activate && pip install -r requirements.txt && deactivate
	@$(MAKE) set_permissions  

# Install ComfyUI
install_comfyui: create_install_dir
	@echo "Cloning ComfyUI..."
	@-git clone $(COMFYUI_REPO) $(INSTALL_DIR)/comfyui
	@echo "Setting up venv for ComfyUI..."
	@cd $(INSTALL_DIR)/comfyui && python3 -m venv venv 
    # Install custom torch first
	@cd $(INSTALL_DIR)/comfyui && source venv/bin/activate && pip install  torch torchvision torchaudio xformers --index-url $(CUDA_TORCH)  && deactivate
	@cd $(INSTALL_DIR)/comfyui && source venv/bin/activate && pip install -r requirements.txt && deactivate
	@$(MAKE) set_permissions  

install: install_nginx configure_nginx install_sdwebui install_comfyui install_ai_manager

# Install Nginx
install_nginx:
	@echo "Installing Nginx..."
	@dnf install -y nginx

# Configure Nginx
configure_nginx:
	@echo "Checking if Nginx configuration exists..."
	@if [ -f /etc/nginx/nginx.conf ]; then \
		echo "Backing up existing Nginx configuration..."; \
		cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak; \
	else \
		echo "Nginx configuration not found, skipping backup."; \
	fi
	@echo "Configuring Nginx..."
	@cp etc/nginx/nginx.conf /etc/nginx/nginx.conf
	@sed -i "s|SERVER_NAME|$(SERVER_NAME)|g" /etc/nginx/nginx.conf
	@echo "Testing Nginx configuration..."
	@nginx -t
	@if [ $$? -eq 0 ]; then \
		echo "Restarting Nginx..."; \
		systemctl restart nginx; \
		echo "Nginx configuration applied successfully."; \
	else \
		echo "Nginx configuration test failed. Restoring previous configuration."; \
		if [ -f /etc/nginx/nginx.conf.bak ]; then \
			cp /etc/nginx/nginx.conf.bak /etc/nginx/nginx.conf; \
			systemctl restart nginx; \
			echo "Restored previous Nginx configuration."; \
		else \
			echo "Backup not found, cannot restore previous configuration."; \
		fi \
	fi

