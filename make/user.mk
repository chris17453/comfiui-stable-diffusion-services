 include make/config.mk

# Create the group if it doesn't exist and create ai_manager user
create_user_group:
	@echo "Creating $(SERVICE_GROUP) group if it doesn't exist..."
	@groupadd -f $(SERVICE_GROUP)
	@echo "Creating $(SERVICE_USER) user and adding to $(SERVICE_GROUP)..."
	@useradd -m -s /bin/bash $(SERVICE_USER) || echo "User $(SERVICE_USER) already exists."
	@usermod -aG $(SERVICE_GROUP) $(SERVICE_USER)
	@echo "User $(SERVICE_USER) added to $(SERVICE_GROUP)..."


# Create sudoers file for ai-manager
create_sudoers_file:
	@echo "Creating sudoers file for $(SERVICE_USER)..."
	@echo "$(SERVICE_USER) ALL=(ALL) NOPASSWD: /bin/systemctl start ai_manager.service, /bin/systemctl stop ai_manager.service, /bin/systemctl restart ai_manager.service, /bin/systemctl is-active ai_manager.service" | sudo tee /etc/sudoers.d/ai-manager >/dev/null
	@echo "$(SERVICE_USER) ALL=(ALL) NOPASSWD: /bin/systemctl start comfyui.service, /bin/systemctl stop comfyui.service, /bin/systemctl restart comfyui.service, /bin/systemctl is-active comfyui.service" | sudo tee -a /etc/sudoers.d/ai-manager >/dev/null
	@echo "$(SERVICE_USER) ALL=(ALL) NOPASSWD: /bin/systemctl start sdwebui.service, /bin/systemctl stop sdwebui.service, /bin/systemctl restart sdwebui.service, /bin/systemctl is-active sdwebui.service" | sudo tee -a /etc/sudoers.d/ai-manager >/dev/null
	@echo "Sudoers file created at /etc/sudoers.d/ai-manager"
	@chmod 0440 /etc/sudoers.d/ai-manager
	@echo "Validating sudoers file..."
	@visudo -c || (echo "Sudoers validation failed. Please check the syntax." && exit 1)

# Combined target to create the user, group, update sudoers, and set permissions
create_sa: create_user_group create_sudoers_file set_permissions
	@echo "$(SERVICE_USER) user setup complete with sudo permissions."

# Set permissions for the /opt/AI directory
set_permissions:
	@echo "Setting permissions for $(INSTALL_DIR) directory..."
	@chown -R $(SERVICE_USER):$(SERVICE_GROUP) $(INSTALL_DIR)
	@chmod -R 775 $(INSTALL_DIR)

# Create the installation directory if it doesn't exist
create_install_dir:
	@if [ ! -d "$(INSTALL_DIR)" ]; then \
		echo "Creating installation directory $(INSTALL_DIR)..."; \
		mkdir -p $(INSTALL_DIR); \
	else \
		echo "Installation directory $(INSTALL_DIR) already exists."; \
	fi

