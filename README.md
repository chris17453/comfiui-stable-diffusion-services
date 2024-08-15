# ComfyUI and Stable Diffusion Web UI Setup

This repository contains the necessary configuration files and a setup script to install and run both ComfyUI and Stable Diffusion Web UI (AUTOMATIC1111) on your server. The setup includes systemd service files and an Nginx configuration for remote access.

## Table of Contents

- [Overview](#overview)
- [Setup Process](#setup-process)
- [Configuration Changes](#configuration-changes)
- [How to Use](#how-to-use)
- [Troubleshooting](#troubleshooting)

## Overview

This setup allows you to run either ComfyUI or Stable Diffusion Web UI on your server, with Nginx acting as a reverse proxy to make them accessible remotely. Both services are managed by systemd, ensuring they start automatically at boot and restart if they fail.

### Important Note: 
- **Only one UI service can run at a time** due to port conflicts and resource contention (CUDA), though if you want both.. let me know and I'll update the script.
- **Customization Required**: The provided script and configuration files contain placeholders that you need to update to match your specific environment.


## Setup Process

### 1. Clone the Repository

First, clone this repository to your server:

```bash
git clone https://github.com/yourusername/comfiui-stable-diffusion-services.git 
cd comfiui-stable-diffusion-services
```

### 2. Run the Setup Script

The setup script will:

- Clone the ComfyUI and Stable Diffusion Web UI repositories.
- Set up Python virtual environments (venvs) for both.
- Copy and configure the systemd service files.
- Install and configure Nginx.

To run the script, make it executable and execute it:

```bash
chmod +x setup.sh
./setup.sh
```

### 3. Enter Your Server Name

When prompted by the setup script, enter your server name (e.g., `gpu2.watkinslabs.com`). This will configure Nginx to use your specified server name.

### 4. Verify the Setup

Once the script completes, open your web browser and navigate to your domain or IP address (e.g., `http://gpu2.watkinslabs.com`) to ensure the UI is accessible.

## Configuration Changes

### 1. Customize Service Files

The service files located in the `/etc/systemd/system/` directory contain placeholders that must be updated, setup script does this for you, but a manual edit works as well.

- **INSTALL_DIR**: Replace this placeholder in the service files with the actual path where you installed the services.


Example:

```bash
sudo sed -i "s|INSTALL_DIR|/home/your_username|g" /etc/systemd/system/sdwebui.service
sudo sed -i "s|INSTALL_DIR|/home/your_username|g" /etc/systemd/system/comfyui.service
```

### 2. Nginx Configuration

The Nginx configuration file (`nginx/nginx.conf`) contains a placeholder for your server name, setup.sh does this for you but you can change it manualy as well.:

- **SERVER_NAME**: This placeholder will be replaced by the setup script based on your input.

Example:

```bash
sudo sed -i "s|SERVER_NAME|yourdomain.com|g" /etc/nginx/nginx.conf
```

## How to Use

### Start and Enable the Services

Once the script has been executed and configuration files updated, you can start and enable the services:

For Stable Diffusion Web UI:

```bash
sudo systemctl start sdwebui.service
sudo systemctl enable sdwebui.service
```

For ComfyUI:

```bash
sudo systemctl start comfyui.service
sudo systemctl enable comfyui.service
```

### Switching Between Services

To switch between Stable Diffusion Web UI and ComfyUI, stop the currently running service and start the other:

```bash
sudo systemctl stop sdwebui.service
sudo systemctl start comfyui.service
```

Repeat the process as needed to switch back.

## Troubleshooting

- **Service Fails to Start**: Check the service status with `sudo systemctl status sdwebui.service` or `sudo systemctl status comfyui.service` to see any error messages.
- **Web UI Not Loading**: Ensure Nginx is running and the services are active. Check Nginx logs in `/var/log/nginx/error.log`.
- **Permission Issues**: Ensure that the services are running under the correct user and that the directories have the necessary permissions.


## Logs

Logs for both services and Nginx are stored in the `/var/log/` directory. These logs are useful for troubleshooting any issues that arise.

### Stable Diffusion Web UI Logs

- **Standard Output**: `/var/log/sdwebui.log`
- **Standard Error**: `/var/log/sdwebui.log`

### ComfyUI Logs

- **Standard Output**: `/var/log/comfyui.log`
- **Standard Error**: `/var/log/comfyui.log`

### Nginx Logs

- **Error Log**: `/var/log/nginx/error.log`
- **Access Log**: `/var/log/nginx/access.log`

To view the logs, you can use the `cat`, `less`, or `tail -f` commands. For example:

```bash
# View the latest logs for Stable Diffusion Web UI
tail -f /var/log/sdwebui.log

# View the latest logs for ComfyUI
tail -f /var/log/comfyui.log

# View Nginx error logs
tail -f /var/log/nginx/error.log
```


