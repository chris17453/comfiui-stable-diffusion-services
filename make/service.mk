include ./make/config.mk

# Install and configure services
create_services:
	@echo "Configuring systemd services..."
	@cp etc/systemd/system/sdwebui.service /etc/systemd/system/
	@cp etc/systemd/system/comfyui.service /etc/systemd/system/
	@cp etc/systemd/system/ai_manager.service /etc/systemd/system/
	@sed -i "s|INSTALL_DIR|$(INSTALL_DIR)|g" /etc/systemd/system/sdwebui.service
	@sed -i "s|INSTALL_DIR|$(INSTALL_DIR)|g" /etc/systemd/system/comfyui.service
	@sed -i "s|INSTALL_DIR|$(INSTALL_DIR)|g" /etc/systemd/system/ai_manager.service
	@sed -i "s|SERVICE_USER|$(SERVICE_USER)|g" /etc/systemd/system/sdwebui.service
	@sed -i "s|SERVICE_USER|$(SERVICE_USER)|g" /etc/systemd/system/comfyui.service
	@sed -i "s|SERVICE_USER|$(SERVICE_USER)|g" /etc/systemd/system/ai_manager.service
	@sed -i "s|SERVICE_GROUP|$(SERVICE_GROUP)|g" /etc/systemd/system/sdwebui.service
	@sed -i "s|SERVICE_GROUP|$(SERVICE_GROUP)|g" /etc/systemd/system/comfyui.service
	@sed -i "s|SERVICE_GROUP|$(SERVICE_GROUP)|g" /etc/systemd/system/ai_manager.service	
	@systemctl daemon-reload
