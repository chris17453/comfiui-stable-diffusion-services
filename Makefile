# Check if running as sudo
ifndef SUDO_USER
    $(error This Makefile must be run as root or using sudo)
endif


include make/commands.mk
include make/install.mk
include make/service.mk
include make/user.mk

.PHONY: all install_services install_sdwebui install_comfyui install_nginx configure_nginx stop_services enable_sdwebui enable_comfyui disable_services



# Default target: Display help message
help:
	@echo "Usage: make [TARGET]"
	@echo ""
	@echo "Available targets:"
	@echo "  Main Group:"
	@echo "    all                  Create the service account, down and install all apps and install and activate services"
	@echo "    install              Install all of the apps"
	@echo "    setup                Install and configure systemd services for each app"
	@echo " "
	@echo "  Install the apps:"
	@echo "    install_nginx        Download and Install Nginx"
	@echo "    install_sdwebui      Download and Install Stable Diffusion Web UI app"
	@echo "    install_comfyui      Download and Install ComfyUI app"
	@echo "    install_ai_manager   Install the python web app ai_manager app to the installation directory"
	@echo " "
	@echo "  Running Things"
	@echo "    AI-Manager"
	@echo "      enable_ai_manager    Enable ai_manager on boot (web app for switching)"
	@echo "      disable_ai_manager   Disable the ai_manager service"
	@echo "      start_ai_manager     Start the ai_manager service"
	@echo "      stop_ai_manager      Stop the ai_manager service"
	@echo "    Stable Diffusion "
	@echo "      enable_sdwebui       Enable Stable Diffusion Web UI (and disable ComfyUI)"
	@echo "    ComfyUI "
	@echo "      enable_comfyui       Enable ComfyUI (and disable Stable Diffusion Web UI)"
	@echo "    Global "
	@echo "      disable_services     Disable both sdwebui and comfyui services"
	@echo "      stop_services        Stop all 3 services"



all: create_sa install_apps create_services