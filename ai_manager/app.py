import gradio as gr
import subprocess
import time

# Function to check service status
def check_service_status(service_name):
    result = subprocess.run(['sudo', 'systemctl', 'is-active', service_name], stdout=subprocess.PIPE)
    return result.stdout.decode('utf-8').strip()

# Function to activate the service and return the updated status
def activate_service(service_name):
    subprocess.run(['sudo', 'systemctl', 'start', service_name])
    # Deactivate the other service to ensure only one is active
    if service_name == 'comfyui.service':
        subprocess.run(['sudo', 'systemctl', 'stop', 'sdwebui.service'])
    else:
        subprocess.run(['sudo', 'systemctl', 'stop', 'comfyui.service'])
    time.sleep(5)  # Adjust the delay time as needed
    return get_full_status()

# Function to deactivate all services
def deactivate_all_services():
    subprocess.run(['sudo', 'systemctl', 'stop', 'comfyui.service'])
    subprocess.run(['sudo', 'systemctl', 'stop', 'sdwebui.service'])
    time.sleep(5)  # Adjust the delay time as needed
    return get_full_status()

# Function to check statuses initially
def check_status():
    comfyui_status = check_service_status('comfyui.service')
    sd_status = check_service_status('sdwebui.service')
    return comfyui_status, sd_status

# Function to get all status and link content
def get_full_status():
    comfyui_status_value, sd_status_value = check_status()
    comfyui_link_content = "[Open ComfyUI](/)" if comfyui_status_value == "active" else ""
    sd_link_content = "[Open Stable Diffusion](/)" if sd_status_value == "active" else ""
    return comfyui_status_value, sd_status_value, comfyui_link_content, sd_link_content

# Gradio interface layout
with gr.Blocks() as app:
    gr.Markdown("# AI Manager")

    comfyui_status = gr.Textbox(label="Comfy UI Status", interactive=False)
    sd_status = gr.Textbox(label="Stable Diffusion Status", interactive=False)

    comfyui_link = gr.Markdown("")
    sd_link = gr.Markdown("")

    # Load current statuses and update the interface
    app.load(fn=get_full_status, inputs=[], outputs=[comfyui_status, sd_status, comfyui_link, sd_link])

    activate_comfyui_btn = gr.Button("Activate Comfy UI")
    activate_comfyui_btn.click(fn=lambda: activate_service('comfyui.service'), inputs=[], outputs=[comfyui_status, sd_status, comfyui_link, sd_link])

    activate_sdwebui_btn = gr.Button("Activate Stable Diffusion")
    activate_sdwebui_btn.click(fn=lambda: activate_service('sdwebui.service'), inputs=[], outputs=[comfyui_status, sd_status, comfyui_link, sd_link])

    deactivate_all_btn = gr.Button("Deactivate All Services")
    deactivate_all_btn.click(fn=deactivate_all_services, inputs=[], outputs=[comfyui_status, sd_status, comfyui_link, sd_link])

# Launch the app on port 5000
app.launch(server_name="127.0.0.1", server_port=5000, root_path="/ai_manager")

