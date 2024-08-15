#!/bin/bash

# Variables
SD_WEBUI_REPO="https://github.com/AUTOMATIC1111/stable-diffusion-webui.git"
COMFYUI_REPO="https://github.com/comfyanonymous/ComfyUI.git"
INSTALL_DIR="/path/to/install"
SERVER_NAME="gpu2.watkinslabs.com"

# Prompt for server name
read -p "Enter your server name (e.g., gpu2.watkinslabs.com): " SERVER_NAME

# Clone repositories
echo "Cloning Stable Diffusion Web UI..."
git clone $SD_WEBUI_REPO $INSTALL_DIR/stable-diffusion-webui

echo "Cloning ComfyUI..."
git clone $COMFYUI_REPO $INSTALL_DIR/comfyui

# Set up virtual environments
echo "Setting up venv for Stable Diffusion Web UI..."
cd $INSTALL_DIR/stable-diffusion-webui
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
deactivate

echo "Setting up venv for ComfyUI..."
cd $INSTALL_DIR/comfyui
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
deactivate

# Copy and configure systemd services
echo "Configuring systemd services..."
sudo cp etc/system/sdwebui.service /etc/systemd/system/
sudo cp etc/system/comfyui.service /etc/systemd/system/
sudo cp etc/system/ai_manager.service /etc/systemd/system/

# Replace placeholders in service files
sudo sed -i "s|INSTALL_DIR|$INSTALL_DIR|g" /etc/systemd/system/sdwebui.service
sudo sed -i "s|INSTALL_DIR|$INSTALL_DIR|g" /etc/systemd/system/comfyui.service
sudo sed -i "s|INSTALL_DIR|$INSTALL_DIR|g" /etc/systemd/system/ai_manager.service

sudo systemctl daemon-reload

# Install and configure Nginx
echo "Installing Nginx..."
sudo apt update
sudo apt install -y nginx

# Back up the existing Nginx configuration
echo "Backing up existing Nginx configuration..."
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

# Copy the new Nginx configuration
echo "Configuring Nginx..."
sudo cp nginx/nginx.conf /etc/nginx/nginx.conf

# Update server name in Nginx configuration
sudo sed -i "s|SERVER_NAME|$SERVER_NAME|g" /etc/nginx/nginx.conf

# Test the new Nginx configuration and restart the server
echo "Testing Nginx configuration..."
sudo nginx -t

if [ $? -eq 0 ]; then
    echo "Restarting Nginx..."
    sudo systemctl restart nginx
    echo "Nginx configuration applied successfully."
else
    echo "Nginx configuration test failed. Restoring previous configuration."
    sudo cp /etc/nginx/nginx.conf.bak /etc/nginx/nginx.conf
    sudo systemctl restart nginx
    echo "Restored previous Nginx configuration."
fi

# reload the services because they've been changed
sudo systemctl daemon-reload
## start on boot
sudo systemctl enable ai_manager.service


echo "Setup complete! Use the following commands to start services:"
echo "sudo systemctl start ai_manager.service"
echo "sudo systemctl start sdwebui.service"
echo "sudo systemctl start comfyui.service"
